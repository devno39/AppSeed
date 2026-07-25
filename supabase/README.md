# Supabase

Server side of the app: Postgres (RLS + SECURITY DEFINER RPCs), Realtime, Storage,
and the edge functions below. This directory is a **template seed** — the SQL and
the edge function are canonical starting points, not a live deployment. Wire them
into the next app's own Supabase project, fill the env placeholders, and deploy.

## Edge functions

| Function | Role |
|---|---|
| `send-push/` | Push pipeline worker. Invoked by pg_cron with a batch of `push_outbox` row IDs: loads outbox rows + recipient device tokens, mints an APNs ES256 JWT (cached), builds channel-specific APNs payloads, fans out to APNs per token environment, prunes dead tokens. |

Deploying an edge function change is mandatory before testing from iOS — local edits
do nothing until deployed.

## Push pipeline — 4 hard rules

Every push-related change must respect all four. Each rule exists because breaking it
produced a production-grade bug in the app this seed was harvested from.

### 1. Hybrid payloads are forbidden
Never combine `aps.alert` with `content-available: 1`. iOS launches the app in
background mode and races the banner tap — a cold launch dies before the first scene
renders.
- Visible push (`apns-push-type: alert`): no `content-available`. The NSE fires via
  `mutable-content: 1`, which is enough for widget reloads.
- Silent push (`apns-push-type: background`): `content-available` required.

### 2. One event = one `push_outbox` row
Never write a silent + a visible row for the same event — delivery order is not
guaranteed, the NSE double-fires, and APNs may drop the silent one. Want a banner
**and** a widget refresh? One row: `channel='visible'` + `kinds=['SomeWidget']` — the
NSE reads `kinds` and reloads timelines.
- Review rule: two `INSERT INTO push_outbox` in one trigger → stop and question it.
- A drain coalescer can group pending rows by (recipient, channel, title key) so
  same-window visible pushes of the same kind merge.

### 3. Deploy order for new loc-keys: client first
If a trigger sends a `visible_title_key`/`visible_body_key` the installed client
doesn't have, iOS shows the RAW KEY in the banner.
- New key: xcstrings + translations → client released ("Ready for Sale") → **then**
  deploy the migration.
- Key already present in shipped versions → early deploy is safe.
- Inverse rule (the RPC exception): if the sender is a client button (an RPC the user
  taps), the migration deploys **before** the client — nobody can call the RPC without
  the button, so there is no window where an old client emits an unknown key.
- Loc-keys resolve in the **system** language, not the app's in-app language selection.

### 4. Silent push / cold-launch race
Silent pushes launch the app in the background, which races the splash. The permanent
defense (harvested as `SplashViewController.startWhenForeground()` + a SceneDelegate
fallback) holds the UI until the app is actually foregrounded:
- `handleSilentPush` must guard `currentUser == nil` (cold launch, session not loaded).
- No heavy work (realtime subscribe, multi-fetch) on background launches.
- Any change adding a silent trigger must pass this device test: trigger silent →
  wait 10s → tap the app **icon** (not a banner) → the splash must flow.

## Migration conventions

- Migrations are numbered `NNN_short_name.sql` (`001`, `002`, …) and applied via the
  Supabase SQL editor in order.
- The **latest migration body is the source of truth** for a function/trigger: always
  edit the newest copy of a definition, never an older one. When a definition changes,
  add a new numbered migration that `CREATE OR REPLACE`s it — the history stays as an
  append-only log, and the highest number wins.
- Templates live under `templates/sql/`. Copy them into the app's real migration
  sequence and renumber as needed.
