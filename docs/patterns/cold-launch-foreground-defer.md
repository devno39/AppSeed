# Pattern: Cold-launch foreground defer (+ update-gate grace)

## Problem

A silent push (`content-available: 1`) can cold-launch the app **in the
background**. The Splash is the root scene, but routing from a background launch is
dropped — there's no foreground scene to present into — so the splash sticks
forever and the user taps the icon into a dead screen. Worse, scene connect reports
`.background` even on a normal icon launch, so you can't distinguish the two at
connect time.

A second, related hazard: the launch flow waits on a remote config fetch (version
gate). A slow network then holds the splash hostage indefinitely.

## Mechanism

**1. Defer the whole flow until actually foregrounded.** On `viewDidLoad`, if the
app is `.background`, don't run the flow — subscribe to
`willEnterForegroundNotification` and run it there. This costs nothing on a normal
launch (the notification fires moments later) and fixes the background cold launch:

```swift
private func startWhenForeground() {
    guard UIApplication.shared.applicationState == .background else {
        checkUpdate(); return
    }
    foregroundObserver = NotificationCenter.default.addObserver(
        forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main
    ) { [weak self] _ in
        guard let self else { return }
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer); foregroundObserver = nil
        }
        checkUpdate()
    }
}
```

**2. Grace-window the version gate.** The config fetch races a timeout; whichever
fires first wins, and the loser is discarded (a `didFinish` latch guarantees the
completion runs exactly once). A slow fetch never blocks routing:

```swift
func checkUpdate(completion: BoolClosure?) {
    var didFinish = false
    let finish: BoolClosure = { needsUpdate in
        guard !didFinish else { return }
        didFinish = true
        completion?(needsUpdate)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { finish(false) }  // grace
    SupabaseAppConfigHelper.shared.fetchAll { _ in
        /* compare app version to remote minimum */ finish(needsUpdate)
    }
}
```

**3. Re-check on return to foreground when an update is required.** If the version
is too old, show the force-update alert and observe foreground again — the user
returning from the App Store re-runs the check. Guard against stacking a second
alert on the one still presented.

## Companion invariants

This is only the client half. The silent-push handler must also:
- guard `currentUser == nil` (cold launch, session not yet loaded),
- do **no** heavy work (realtime subscribe, multi-fetch) on background launches.

And the SceneDelegate provides the fallback path that drains any pending route once
the real root is installed. See the push pipeline rules in `supabase/README.md`
(rule 4). Device test for any new silent trigger: trigger silent → wait 10s → tap
the app **icon** (not a banner) → the splash must flow.

## When to use

Any app that receives silent pushes and does launch-time routing/gating from a
root splash. The grace-window latch (part 2) applies independently to any
launch-blocking async check.

## Where it lives

Seed implementation: `AppSeed/Scenes/Splash/SplashViewController.swift`
(`startWhenForeground()`, `checkUpdate`, `observeForegroundForRecheck`) +
`SplashViewModel.checkUpdate` (grace latch).
