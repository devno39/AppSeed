// send-push — push pipeline worker (template skeleton).
//
// Invoked by pg_cron with a batch of push_outbox row IDs. For each row:
//   1. Load the outbox row + the recipient's device tokens (service role bypasses
//      RLS — this function is the only writer/drainer of push_outbox).
//   2. Mint an APNs ES256 JWT (module-scope cached — see getOrMintJwt).
//   3. Build a channel-specific APNs payload (silent content-available=1, visible
//      alert + mutable-content, NEVER both — hard rule #1, hybrid payloads break
//      the cold-launch banner tap).
//   4. POST to api.{sandbox|push}.apple.com per token (parallel fan-out).
//   5. Handle status codes: 200 dispatched; 410 / 400 BadDeviceToken → delete the
//      token; 403 → cached JWT cleared, retry once with a fresh mint; 429 / 5xx →
//      retry with backoff.
//   6. Update the outbox row bookkeeping.
//
// This is a seed skeleton: no HMAC opaque tags, no per-recipient secret, no
// app-version gating. Add those in the app's own copy if the threat model needs
// them. All identifiers/keys come from env — never hardcode.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

const MAX_OUTBOX_IDS = 200;
const MAX_ATTEMPTS = 3;
const BACKOFF_BASE_SECONDS = 30;
const BACKOFF_MAX_SECONDS = 300;

// APNs 400 reasons that genuinely mean a dead token. All other 400 reasons
// (BadTopic, PayloadEmpty, …) reflect server bugs and must NOT delete the token.
const PERMANENT_400_REASONS = new Set(["BadDeviceToken", "DeviceTokenNotForTopic"]);

const SUPABASE_URL = mustEnv("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = mustEnv("SUPABASE_SERVICE_ROLE_KEY");

// APNs credentials — all placeholders, set as edge-function secrets:
//   APNS_KEY_ID  — the .p8 key's Key ID (10 chars)
//   APNS_TEAM_ID — the Apple Developer Team ID (10 chars)
//   APNS_P8      — the .p8 private key, base64-encoded
//   APNS_TOPIC   — the app bundle id (apns-topic header)
const APNS_TOPIC = mustEnv("APNS_TOPIC");

// TODO: production stores each token's environment (sandbox|production) on the
// device_tokens row and selects the host per token. This skeleton defaults to
// sandbox — switch to "api.push.apple.com" for production builds.
const APNS_HOST = "api.sandbox.push.apple.com";

const admin: SupabaseClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
});

interface OutboxRow {
    id: number;
    recipient_user_id: string;
    channel: "silent" | "visible";
    kinds: string[];
    visible_title_key: string | null;
    visible_body_key: string | null;
    visible_loc_args: unknown[] | null;
    attempts: number;
}

Deno.serve(async (req) => {
    try {
        const body = await req.json().catch(() => null) as { outbox_ids?: unknown } | null;
        if (!body || !Array.isArray(body.outbox_ids)) {
            return json({ error: "outbox_ids required (array of positive integers)" }, 400);
        }
        if (body.outbox_ids.length > MAX_OUTBOX_IDS) {
            return json({ error: `outbox_ids length exceeds ${MAX_OUTBOX_IDS}` }, 400);
        }

        const ids = body.outbox_ids.filter(
            (id): id is number => typeof id === "number" && Number.isInteger(id) && id > 0,
        );
        if (ids.length === 0) return json({ error: "no valid outbox_ids" }, 400);

        const results = [];
        for (const id of ids) {
            results.push(await processOutboxId(id));
        }
        return json({ ok: true, results }, 200);
    } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error("top-level error:", msg);
        return json({ error: "internal error" }, 500);
    }
});

async function processOutboxId(outboxId: number) {
    const { data: row, error: rowErr } = await admin.from("push_outbox")
        .select("id, recipient_user_id, channel, kinds, visible_title_key, visible_body_key, visible_loc_args, attempts")
        .eq("id", outboxId)
        .maybeSingle();

    if (rowErr) throw new Error(`outbox load failed: ${rowErr.message}`);
    if (!row) return { outbox_id: outboxId, status: "skipped" };

    const typed = row as OutboxRow;

    if (typed.attempts >= MAX_ATTEMPTS) {
        await markFailed(outboxId, `max attempts (${MAX_ATTEMPTS}) reached`);
        return { outbox_id: outboxId, status: "failed" };
    }

    // Pre-bump attempts + next_attempt_at BEFORE sending. If this invocation crashes
    // mid-send (or the runtime is killed), the row won't be re-drained until the
    // backoff window elapses — that is what stops a poison row from hot-looping.
    await bumpAttempt(outboxId, typed.attempts);

    const { data: tokens, error: tokErr } = await admin.from("device_tokens")
        .select("token")
        .eq("user_id", typed.recipient_user_id);

    if (tokErr) throw new Error(`device_tokens load failed: ${tokErr.message}`);
    const tokenList = (tokens ?? []).map((t) => (t as { token: string }).token);

    if (tokenList.length === 0) {
        await markDispatched(outboxId); // nothing to send is a terminal success
        return { outbox_id: outboxId, status: "no_targets" };
    }

    const payload = typed.channel === "silent"
        ? buildSilentPayload(typed.kinds)
        : buildVisiblePayload(typed);
    const bodyText = JSON.stringify(payload);

    const settlements = await Promise.allSettled(
        tokenList.map((token) => sendWith403Retry(token, typed.channel, bodyText)),
    );

    let sent = 0;
    let shouldRetry = false;
    const errors: string[] = [];
    const deletions: Promise<unknown>[] = [];

    for (let i = 0; i < settlements.length; i++) {
        const token = tokenList[i];
        const s = settlements[i];
        if (s.status === "rejected") {
            shouldRetry = true;
            errors.push(`fetch failed: ${String(s.reason)}`);
            continue;
        }
        const status = s.value;
        if (status.code >= 200 && status.code < 300) {
            sent++;
        } else if (status.code === 410 || (status.code === 400 && status.reason && PERMANENT_400_REASONS.has(status.reason))) {
            deletions.push(admin.from("device_tokens").delete().eq("token", token));
            errors.push(`${status.code} ${status.reason ?? "Unregistered"} → deleted`);
        } else if (status.code === 429 || status.code >= 500 || status.code === 403) {
            shouldRetry = true;
            errors.push(`${status.code} ${status.reason ?? "transient"} (will retry)`);
        } else {
            errors.push(`${status.code} ${status.reason ?? "unexpected"}`);
        }
    }

    if (deletions.length > 0) await Promise.allSettled(deletions);

    if (sent > 0) {
        await markDispatched(outboxId);
        return { outbox_id: outboxId, status: "dispatched", sent, errors };
    }
    if (shouldRetry) {
        // next_attempt_at already bumped; just record the error.
        await recordError(outboxId, errors.join(" | "));
        return { outbox_id: outboxId, status: "retry", errors };
    }
    await markFailed(outboxId, errors.join(" | "));
    return { outbox_id: outboxId, status: "failed", errors };
}

// =====================================================
// APNs payloads — hybrid (alert + content-available) is forbidden (hard rule #1).
// =====================================================
function buildSilentPayload(kinds: string[]): Record<string, unknown> {
    return { aps: { "content-available": 1 }, payload_version: 1, kinds };
}

function buildVisiblePayload(row: OutboxRow): Record<string, unknown> {
    const alert: Record<string, unknown> = {};
    if (row.visible_title_key) alert["title-loc-key"] = row.visible_title_key;
    if (row.visible_body_key) alert["loc-key"] = row.visible_body_key;
    if (row.visible_loc_args && row.visible_loc_args.length > 0) {
        alert["title-loc-args"] = row.visible_loc_args;
        if (row.visible_body_key) alert["loc-args"] = row.visible_loc_args;
    }
    // Pure visible push — NO content-available. mutable-content:1 wakes the NSE for
    // widget reloads without the background-launch race a hybrid payload would cause.
    return {
        aps: { alert, sound: "default", badge: 1, "mutable-content": 1 },
        payload_version: 2,
        kinds: row.kinds,
    };
}

// =====================================================
// APNs HTTP/2 send + single 403 retry (fresh JWT).
// =====================================================
interface ApnsStatus { code: number; reason?: string; }

async function sendWith403Retry(token: string, channel: string, bodyText: string): Promise<ApnsStatus> {
    let status = await sendApns(token, channel, bodyText);
    if (status.code === 403) status = await sendApns(token, channel, bodyText); // cachedJwt cleared on 403
    return status;
}

async function sendApns(token: string, channel: string, bodyText: string): Promise<ApnsStatus> {
    const jwt = await getOrMintJwt();
    const response = await fetch(`https://${APNS_HOST}/3/device/${token}`, {
        method: "POST",
        headers: {
            authorization: `bearer ${jwt}`,
            "apns-topic": APNS_TOPIC,
            "apns-push-type": channel === "silent" ? "background" : "alert",
            "apns-priority": channel === "silent" ? "5" : "10",
            "content-type": "application/json",
        },
        body: bodyText,
    });

    if (response.status >= 200 && response.status < 300) return { code: response.status };

    let reason: string | undefined;
    try {
        const errBody = await response.json() as { reason?: string };
        if (typeof errBody?.reason === "string") reason = errBody.reason;
    } catch { /* ignore parse errors */ }

    // Any 403 (Expired/Invalid/MissingProviderToken) means the cached JWT is unusable.
    if (response.status === 403) cachedJwt = null;
    return { code: response.status, reason };
}

// =====================================================
// JWT minting (ES256) — module-scope cache so warm invocations don't re-mint.
// Apple soft-throttles above ~1 mint / 20 min; a 50-min TTL keeps us well under.
// =====================================================
interface CachedJwt { token: string; expiresAtMs: number; }
let cachedJwt: CachedJwt | null = null;
let cryptoKey: CryptoKey | null = null;
const JWT_LIFETIME_MS = 50 * 60 * 1000;
const JWT_EXP_SECONDS = 55 * 60; // just under Apple's 60-min iat tolerance

async function getOrMintJwt(): Promise<string> {
    const now = Date.now();
    if (cachedJwt && cachedJwt.expiresAtMs > now + 60_000) return cachedJwt.token;

    const keyId = mustEnv("APNS_KEY_ID");
    const teamId = mustEnv("APNS_TEAM_ID");
    const key = cryptoKey ?? await importApnsKey();
    cryptoKey = key;

    const iat = Math.floor(now / 1000);
    const header = { alg: "ES256", kid: keyId, typ: "JWT" };
    const payload = { iss: teamId, iat, exp: iat + JWT_EXP_SECONDS };
    const signingInput = `${b64url(new TextEncoder().encode(JSON.stringify(header)))}.${b64url(new TextEncoder().encode(JSON.stringify(payload)))}`;
    const signature = await crypto.subtle.sign({ name: "ECDSA", hash: "SHA-256" }, key, new TextEncoder().encode(signingInput));
    const token = `${signingInput}.${b64url(new Uint8Array(signature))}`;

    cachedJwt = { token, expiresAtMs: now + JWT_LIFETIME_MS };
    return token;
}

async function importApnsKey(): Promise<CryptoKey> {
    const pem = atob(mustEnv("APNS_P8"));
    const base64 = pem.replace(/-----BEGIN PRIVATE KEY-----/, "").replace(/-----END PRIVATE KEY-----/, "").replace(/\s+/g, "");
    const binary = atob(base64);
    const pkcs8 = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) pkcs8[i] = binary.charCodeAt(i);
    return await crypto.subtle.importKey("pkcs8", pkcs8, { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"]);
}

// =====================================================
// push_outbox bookkeeping
// =====================================================
async function bumpAttempt(outboxId: number, currentAttempts: number): Promise<void> {
    const backoff = Math.min(BACKOFF_MAX_SECONDS, BACKOFF_BASE_SECONDS * Math.pow(2, currentAttempts));
    await admin.from("push_outbox").update({
        attempts: currentAttempts + 1,
        next_attempt_at: new Date(Date.now() + backoff * 1000).toISOString(),
    }).eq("id", outboxId);
}

async function markDispatched(outboxId: number): Promise<void> {
    await admin.from("push_outbox").update({ dispatched_at: new Date().toISOString() }).eq("id", outboxId);
}

async function recordError(outboxId: number, error: string): Promise<void> {
    await admin.from("push_outbox").update({ last_error: truncate(error, 500) }).eq("id", outboxId);
}

async function markFailed(outboxId: number, error: string): Promise<void> {
    await admin.from("push_outbox").update({ failed_at: new Date().toISOString(), last_error: truncate(error, 500) }).eq("id", outboxId);
}

// =====================================================
// Helpers
// =====================================================
function b64url(bytes: Uint8Array): string {
    let binary = "";
    for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
    return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function json(body: unknown, status: number): Response {
    return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

function truncate(s: string, max: number): string {
    return s.length > max ? s.slice(0, max) + "...(truncated)" : s;
}

function mustEnv(key: string): string {
    const value = Deno.env.get(key);
    if (!value) throw new Error(`missing env var: ${key}`);
    return value;
}
