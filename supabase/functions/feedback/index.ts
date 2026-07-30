// feedback — server-side proxy between the app and wherever support messages land.
//
// The point of this function is that the destination's credentials never ship in
// the app bundle. A client that can read the token can spam or hijack the support
// channel; here the token lives in Edge Function secrets and clients only ever
// send free text.
//
// Deployed with --no-verify-jwt: sign-in failures are exactly the reports worth
// receiving, and those happen before a session exists. Auth being open is the
// reason for the defences below — 4KB body cap and a per-IP token bucket.
//
// Env secrets required:
//   - TELEGRAM_BOT_TOKEN
//   - TELEGRAM_CHANNEL_ID
// Swapping the sink (Slack webhook, email, a Postgres table) means replacing the
// forward step at the bottom; the client contract stays the same.
//
// Client contract (see FeedbackHelper.swift):
//   POST { text: string, parse_mode?: "HTML" | "Markdown" }
//   → { ok: true } | { error: string }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const MAX_TEXT_BYTES = 4 * 1024; // Telegram's own limit is 4096 chars

// In-memory per-IP bucket. Each worker keeps its own state, which is enough for
// the threat model: casual spam from one IP gets cut off inside a worker, and a
// distributed flood is the sink's rate limits to absorb.
const RATE_WINDOW_MS = 5 * 60 * 1000;
const RATE_LIMIT = 10;
const MAP_CLEANUP_THRESHOLD = 5000;
const rateMap = new Map<string, number[]>();

function clientIp(req: Request): string {
  return (
    req.headers.get("cf-connecting-ip") ??
    req.headers.get("x-forwarded-for")?.split(",")[0].trim() ??
    "unknown"
  );
}

function checkRateLimit(ip: string): { ok: boolean; retryAfter?: number } {
  const now = Date.now();
  const entries = (rateMap.get(ip) ?? []).filter((ts) => now - ts < RATE_WINDOW_MS);

  if (entries.length >= RATE_LIMIT) {
    const retryAfter = Math.ceil((RATE_WINDOW_MS - (now - entries[0])) / 1000);
    return { ok: false, retryAfter };
  }

  entries.push(now);
  rateMap.set(ip, entries);

  if (rateMap.size > MAP_CLEANUP_THRESHOLD) {
    for (const [key, timestamps] of rateMap.entries()) {
      const fresh = timestamps.filter((ts) => now - ts < RATE_WINDOW_MS);
      if (fresh.length === 0) rateMap.delete(key);
      else rateMap.set(key, fresh);
    }
  }

  return { ok: true };
}

interface FeedbackBody {
  text?: string;
  parse_mode?: string;
}

function json(body: unknown, status = 200, extraHeaders: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...extraHeaders },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const rate = checkRateLimit(clientIp(req));
  if (!rate.ok) {
    return json(
      { error: "rate_limited", retry_after_seconds: rate.retryAfter },
      429,
      { "retry-after": String(rate.retryAfter ?? 60) },
    );
  }

  let body: FeedbackBody;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }

  const text = body.text?.trim();
  if (!text) {
    return json({ error: "missing_text" }, 400);
  }
  if (new TextEncoder().encode(text).length > MAX_TEXT_BYTES) {
    return json({ error: "text_too_large" }, 413);
  }

  const botToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
  const channelId = Deno.env.get("TELEGRAM_CHANNEL_ID");
  if (!botToken || !channelId) {
    return json({ error: "server_misconfigured" }, 500);
  }

  const response = await fetch(`https://api.telegram.org/bot${botToken}/sendMessage`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      chat_id: channelId,
      text,
      parse_mode: body.parse_mode ?? "HTML",
    }),
  });

  if (!response.ok) {
    const detail = await response.text().catch(() => "");
    console.error("feedback_forward_failed", { status: response.status, detail });
    return json({ error: "forward_failed", status: response.status }, 502);
  }

  return json({ ok: true });
});
