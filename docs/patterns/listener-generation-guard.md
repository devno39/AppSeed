# Pattern: Listener generation guard (stale-callback defense)

## Problem

A realtime listener's `remove()` unsubscribes **asynchronously**. An in-flight
fetch/callback can therefore complete *after* you've torn the session down
(sign-out, delete account, or an internal listener restart). If that late callback
sets `currentUser` again, it resurrects the dead session: it re-runs first-snapshot
side effects (re-registers push, re-attaches a partner listener), leaks the old
identity into the new one, and fires a `.userDidChange` storm that every tab
observes. Nil-checking the handle isn't enough — the callback already captured its
closure and is mid-flight.

## Mechanism

A monotonically increasing generation counter. Every start **and** stop bumps it;
each callback captures the generation at subscribe time and bails the moment it no
longer matches.

```swift
private var sessionGeneration = 0

func startListening() {
    guard let userId = userService.currentUserId else { return }
    if userListener != nil { stopListening(wipeCache: false) }

    isFirstSnapshot = true
    sessionGeneration += 1
    let generation = sessionGeneration           // captured by the closure

    userListener = userService.listenUser(id: userId) { [weak self] user in
        guard let self, generation == self.sessionGeneration else { return }  // stale → drop
        self.currentUser = user
        if self.isFirstSnapshot {
            self.isFirstSnapshot = false
            /* first-snapshot side effects: last-seen, push register */
        }
        NotificationCenter.default.post(name: .userDidChange, object: nil)
    }
}

func stopListening(wipeCache: Bool) {
    sessionGeneration += 1                        // any in-flight callback is now stale
    /* wipe App Group scope, clear flags, remove listener, nil out currentUser */
}
```

The same guard protects one-shot refreshes that can outlive a teardown:

```swift
func refreshUser() {
    guard let userId = currentUser?.userId else { return }
    let generation = sessionGeneration
    userService.getUser(id: userId) { [weak self] user in
        guard let self, let user, generation == self.sessionGeneration else { return }
        self.currentUser = user
        NotificationCenter.default.post(name: .userDidChange, object: nil)
    }
}
```

Points that make it correct:
- **Bump on stop, not just start** — the stop is what invalidates the outstanding callback.
- **Capture the value, not the property** — the closure compares its frozen `generation` against the live counter.
- **`[weak self]` + `guard let self`** — the manager may itself be gone.
- Pair it with a first-snapshot flag so restart (`start` after an internal `stop`) doesn't re-fire one-time side effects.

## When to use

Any singleton/owner that (a) holds a realtime listener or fires async fetches and
(b) has a teardown boundary (sign-out, delete, unpair, tab dealloc) after which a
late callback would corrupt state. It's the single-owner counterpart to
optimistic-realtime-sync (which handles *concurrent* editors instead).

## Where it lives

Seed implementation: `AppSeed/Helpers/UserSessionManager.swift` (`sessionGeneration`,
captured in `startListening` / `refreshUser`, bumped in `stopListening`). Copy the
counter onto any new session-scoped listener owner.
