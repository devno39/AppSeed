---
title: <one-line implementation title>
type: feat            # feat | refactor | fix | chore
status: draft         # draft | active | shipped | shelved
date: YYYY-MM-DD
# shelved: YYYY-MM-DD
# shelved_reason: |
#   Why this plan was parked (blockers found in a feasibility pass, superseded
#   by another plan, scope re-cut). Point at the successor plan if there is one.
---

# <Title>

> Implementation plan: turns a brainstorm's requirements into ordered, atomic
> units of work. Save as `docs/plans/YYYY-MM-DD-NNN-<type>-<slug>-plan.md`
> (`NNN` = same-day sequence). Plan before code — analyze, present, get approval,
> then implement.

## Overview

One paragraph: what changes, what stays fixed (public API, protocols, VC
bindings), and the size/shape of the result. State the guiding constraint up
front (e.g. "no behavior change; every unit builds + smoke-tests before commit").

## Problem Frame

The current state in facts (file sizes, concern mixing, measured cost) and why
the change is worth doing now. Mirrors the brainstorm's frame but from the
implementation angle.

## Requirements Trace

Map each brainstorm requirement to how this plan satisfies it.

- **R1.** <requirement> → <how this plan delivers it>.
- **R2.** …

## Implementation Units

Ordered, each independently buildable and committable. Keep signatures and
call-site shapes stable across a unit unless the unit is explicitly about that.

### Unit 1 — <name>
- **Files:** <paths touched / created>
- **Change:** <what happens>
- **Verify:** build gate + the manual smoke that proves it (drive the flow, not just compile).
- **Commit:** `<type>: <message>`

### Unit 2 — <name>
- …

## Risks

- **<risk>** — likelihood/impact, and the mitigation or the tripwire that catches it.
- Cross-cutting invariants this touches (widget snapshots, push pipeline, pair
  lifecycle, `.userDidChange` amplification) — call each out explicitly.

## Out of Scope

What this plan deliberately does not do, so review doesn't flag the gaps as misses.
