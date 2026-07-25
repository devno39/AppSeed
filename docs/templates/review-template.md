# Full Project Review — YYYY-MM-DD

> Project-wide review report with a strike-through work-item checklist. Save as
> `docs/reviews/YYYY-MM-DD-<scope>-review.md`. Findings are grouped by severity
> (P0 highest); each is a checkbox so items can be struck as they ship.

<Multi-lens summary line: which lenses ran (standards, state, services, pair
lifecycle, l10n, perf, dead code), how many findings were confirmed vs low
(unverified) vs refuted, and how work items are grouped into sessions.>

Every medium+ finding is adversarially verified before it earns a checkbox —
cite the real `File.swift:line`. A finding that can't be reproduced is refuted,
not listed.

## P0 — Critical

- [ ] **<finding>** — `File.swift:line`. What breaks and for whom. Fix: <approach>.
      When resolved, rewrite the bullet to describe what actually shipped (and any
      bonus/adjacent fix), then check it.

## P1 — <theme, e.g. Error-swallowing family (one root cause, one session)>

- [ ] **<finding>** — `File.swift:line`. …
- [ ] (low) **<lower-confidence finding>** — …

## P2 — <theme>

- [ ] …

## P3 — <theme>
## P4 — Performance
## P5 — Localization
## P6 — Standards debt (MVVM-R canon)
## P7 — Dead code purge (verify-then-delete each)

- [ ] **<finding>** — … For dead-code claims, run the callback + NotificationCenter
      + observer audit before asserting death; note KEPT-by-policy items
      (Extensions/ and Base/UI are library surface) so they aren't re-flagged.
