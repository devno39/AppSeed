// revenuecat-webhook — server-to-server entitlement sync.
//
// The only legitimate writer of users.is_premium / users.premium_until. The app
// reads its own state from the RevenueCat SDK cache; anything server-side reads
// the row, so the row has to track RC's authoritative state.
//
// 006_premium.sql installs a trigger that reverts premium writes from any role
// but service_role — this function connects with the service-role key and is
// therefore the one path through it.
//
// Configuration:
//   - The same secret value in both places:
//       Supabase Edge Function secret REVENUECAT_AUTH_HEADER
//       RevenueCat → Integrations → Webhooks → Authorization header value
//   - SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY are injected automatically.
//
// Mapping rule: expiration_at_ms is the source of truth, so every event type —
// purchase, renewal, cancellation, billing issue, transfer — resolves the same
// way without enumerating them. RC guarantees it reflects the post-event state.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface RCEvent {
  type: string;
  app_user_id?: string;
  product_id?: string;
  expiration_at_ms?: number | null;
}

interface RCWebhookBody {
  event?: RCEvent;
  api_version?: string;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  // RC's standard webhook can only set the Authorization header, not a custom one.
  const expected = Deno.env.get("REVENUECAT_AUTH_HEADER");
  if (!expected) {
    return json({ error: "server_misconfigured" }, 500);
  }
  if (req.headers.get("authorization") !== expected) {
    return json({ error: "unauthorized" }, 401);
  }

  let body: RCWebhookBody;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }

  const event = body.event;
  if (!event?.app_user_id) {
    return json({ error: "missing_app_user_id" }, 400);
  }

  const expirationMs = event.expiration_at_ms ?? null;
  const isPremium = expirationMs != null && expirationMs > Date.now();
  const premiumUntil = isPremium && expirationMs != null
    ? new Date(expirationMs).toISOString()
    : null;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    { auth: { persistSession: false } },
  );

  const { error, count } = await supabase
    .from("users")
    .update({ is_premium: isPremium, premium_until: premiumUntil }, { count: "exact" })
    .eq("user_id", event.app_user_id);

  if (error) {
    console.error("update_failed", { user_id: event.app_user_id, error: error.message });
    return json({ error: "update_failed", message: error.message }, 500);
  }

  if (count === 0) {
    // RC can fire before the client has inserted its users row. Answering 2xx
    // stops the retry storm; the next event reconciles the state.
    console.warn("user_not_found", { user_id: event.app_user_id, event_type: event.type });
  }

  return json({
    ok: true,
    user_id: event.app_user_id,
    is_premium: isPremium,
    premium_until: premiumUntil,
    matched: count ?? 0,
  });
});
