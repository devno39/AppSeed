---
date: YYYY-MM-DD
topic: short-kebab-topic
---

# <Feature / Problem Title>

> Brainstorm doc: frame the problem, land the decisions, and pin numbered
> requirements the plan will trace. Save as
> `docs/brainstorms/YYYY-MM-DD-<topic>-requirements.md`.

## Problem Frame

What's actually broken or missing, in concrete terms. Cite the real files/lines
and the observed behavior — not aspirations. Call out anything explicitly ruled
out of scope and why (speculative, no real consumer yet, belongs to a later
version). One or two paragraphs; end with the chosen direction in a sentence.

## Requirements

Group requirements under sub-headings if the feature has distinct facets
(e.g. "Component Shape", "Loading State", "Migration Parity"). Each requirement
is numbered so the plan and review can trace it.

### <Facet>

- **R1.** <requirement — a single testable statement>. Where a design choice was
  made, name the alternative considered and why this won (the trade-off, briefly).
- **R2.** Commit concrete values here when they're known (sizes, limits, keys) —
  don't defer to planning what the brainstorm already decided.
- **R3.** …

## Key Decisions

Optional. A short list of the load-bearing decisions and their rationale, so the
plan doesn't relitigate them. Each: decision → why → alternative rejected.

## Open Questions

Anything still unresolved that the plan must close before implementation.
