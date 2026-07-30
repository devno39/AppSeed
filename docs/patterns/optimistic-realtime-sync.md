# Pattern: Optimistic realtime sync (optimistic base + capped echo queue + 3-way merge)

> **Reach for this only for a document-shaped row** — one row holding a collection
> that two people co-edit. Ordinary independent rows do not need it, and the seed
> ships the simpler correct answer for those in `Scenes/Main/Items/`: mutate
> locally, let the listener's refetch reconcile, roll back in the completion when
> the write fails. Adopting the merge below for row-per-item data is
> over-engineering, and it teaches the wrong default.

## Problem

Two devices co-edit the same row in real time. A naive listener that overwrites
local state with every server snapshot loses the user's in-flight edits and makes
their own writes "flicker" (local edit → server echo reverts it → next echo
re-applies). You need: (a) own writes never revert, (b) the partner's concurrent
changes merge in, (c) a same-item conflict resolves deterministically, and (d) no
unbounded state that leaks across reconnects.

## Mechanism

Three cooperating pieces, all in the ViewModel that owns the row.

**1. Optimistic base.** Keep `serverBase` = the last snapshot the merge treats as
truth. On a local `save()`, advance the base to the local value *before* sending —
so the next edit isn't misread as a partner change:

```swift
private func save() {
    serverBase = list                 // our write is what the server will hold
    pendingSaves.append(list)
    if pendingSaves.count > 8 {        // cap — reconnect can drop echoes
        pendingSaves.removeFirst(pendingSaves.count - 8)
    }
    taskService.saveTaskList(list, pairId: pairId, completion: nil)
}
```

**2. Capped echo queue.** Every save is appended to `pendingSaves`. When a snapshot
arrives that equals a queued save, it's our own echo — drop it (and everything
before it) and return without touching the UI. The cap (8) bounds the queue so a
dropped echo on reconnect can't linger forever:

```swift
if let index = pendingSaves.firstIndex(of: server) {
    pendingSaves.removeSubrange(...index)
    return
}
if server == list { return }          // no-op snapshot
```

**3. Three-way merge.** For a genuine partner change, merge `server` against
`local` using `base` as the common ancestor: the server wins except where the
local copy has an unsaved delta vs base, which overlays. If the merge kept a local
delta, re-save so both sides converge:

```swift
let merged = Self.mergeList(server: server, local: list, base: base)
guard merged != list else { return }
list = merged
itemsDidChange?()
if merged != server { save() }        // local deltas survived — converge
```

```swift
private static func mergeList(server: T, local: T, base: T) -> T {
    var result = server
    // meta fields: overlay only if locally changed vs base
    if local.name != base.name { result.name = local.name }
    // items keyed by id: server wins, local-changed overlays, local-added kept,
    // local-deleted (present in base, absent locally) stays deleted
    ...
    return result
}
```

Models must be `Equatable` (synthesized is fine) for the echo compare and the
`merged != list` guards.

## When to use

- Any pair/multi-user collection edited concurrently in real time (checklists,
  shared notes, boards).
- **Not** for single-owner state (a user editing only their own row) — that's the
  listener-generation-guard pattern, no merge needed.
- The residual limit: sub-roundtrip simultaneous writes to the *same* item can
  still race because the save upserts the whole row. The full fix is per-item
  server writes (an RPC) — reach for that only when the race actually bites.

## Where it lives

Reference implementation: CoupleOS
`Scenes/Main/Together/Scenes/ListDetail/ListDetailViewModel.swift`
(`save()` / `startListening()` / `mergeList`).

The seed ships two listener shapes, neither of which needs this yet:
`UserSessionManager` (single owner, single row) and `ItemsViewModel` (one row per
item, optimistic write + rollback). Adopt this recipe the first time a single row
holds a collection two people edit at once — put `serverBase` + `pendingSaves` +
a static `merge` on that feature's ViewModel, behind its `{X}ServiceProtocol`
listener.
