//
//  WidgetSyncService.swift
//  AppSeed
//
//  Created by Claude on 26.07.2026.
//

import Foundation

// Orchestrates widget AppGroup writes + WidgetCenter reloads via a handler registry.
// Add a new widget kind by adding a WidgetSyncHandler file + one `register` call at launch.
final class WidgetSyncService {
    static let shared = WidgetSyncService()

    private var handlers: [WidgetSyncKind: WidgetSyncHandler.Type] = [:]
    private var inFlight: Set<WidgetSyncKind> = []
    // A sync requested while the same kind is in flight was silently dropped — remember it
    // and rerun on release so the freshest state always lands.
    private var pendingResync: [WidgetSyncKind: SyncReason] = [:]
    private let lock = NSLock()

    private var appearanceSubscribed = false
    private var appearanceObservers: [NSObjectProtocol] = []

    private init() {}

    // MARK: - Registry
    static func register(_ handlerTypes: [WidgetSyncHandler.Type]) {
        shared.lock.lock()
        for type in handlerTypes {
            shared.handlers[type.kind] = type
        }
        shared.lock.unlock()
        shared.subscribeAppearanceIfNeeded()
    }

    // Palette/theme change triggers resync of color-sensitive kinds.
    private func subscribeAppearanceIfNeeded() {
        guard !appearanceSubscribed else { return }
        appearanceSubscribed = true
        let names: [Notification.Name] = [.paletteDidChange, .themeDidChange]
        appearanceObservers = names.map { name in
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.sync(kinds: Set(WidgetSyncKind.allCases), reason: .manual)
            }
        }
    }

    // MARK: - Sync entry
    // Per-kind reentrancy guard; cheap kinds (<3s) run in parallel, expensive ones get an explicit timeout
    // so background push handlers stay inside iOS's 25-30s budget. Completion fires exactly once.
    func sync(
        kinds: Set<WidgetSyncKind>,
        reason: SyncReason,
        completion: ((SyncResult) -> Void)? = nil
    ) {
        // Capture the session scope on the caller thread (currentUser is written on main,
        // so reading here is safe) before hopping off to file I/O.
        guard let scopeId = UserSessionManager.shared.currentUser?.userId else {
            completion?(.skipped(reason: "no auth session"))
            return
        }

        // Hop off the caller thread before any Keychain read or AppGroup file I/O.
        // Launch-time syncs (sceneDidBecomeActive runs on main) must not touch main.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else {
                completion?(.skipped(reason: "service released"))
                return
            }

            let context = self.currentContext(scopeId: scopeId, reason: reason)

            let registered = kinds.compactMap { kind -> (WidgetSyncKind, WidgetSyncHandler.Type)? in
                guard let handlerType = self.handlers[kind] else { return nil }
                return (kind, handlerType)
            }

            if registered.isEmpty {
                completion?(.skipped(reason: "no handlers registered for requested kinds"))
                return
            }

            let isBackground = reason == .silentPush || reason == .visiblePush
            let expensiveTimeout: TimeInterval = isBackground ? 15 : 25
            let cheapThreshold: TimeInterval = 3

            let (cheap, expensive) = registered.reduce(into: ([(WidgetSyncKind, WidgetSyncHandler.Type)](), [(WidgetSyncKind, WidgetSyncHandler.Type)]())) { acc, pair in
                if pair.1.estimatedDuration < cheapThreshold {
                    acc.0.append(pair)
                } else {
                    acc.1.append(pair)
                }
            }

            let group = DispatchGroup()
            let resultsLock = NSLock()
            var results: [WidgetSyncKind: SyncResult] = [:]

            // Cheap kinds — parallel, no timeout
            for (kind, handlerType) in cheap {
                if !self.claimInFlight(kind, reason: context.reason) {
                    continue
                }
                group.enter()
                handlerType.sync(context: context, timeout: nil) { [weak self] result in
                    self?.releaseInFlight(kind)
                    resultsLock.lock()
                    results[kind] = result
                    resultsLock.unlock()
                    group.leave()
                }
            }

            // Expensive kinds — parallel but with timeout guard
            for (kind, handlerType) in expensive {
                if !self.claimInFlight(kind, reason: context.reason) {
                    continue
                }
                group.enter()
                var completed = false
                let completedLock = NSLock()

                let fireOnce: (SyncResult) -> Void = { [weak self] result in
                    completedLock.lock()
                    defer { completedLock.unlock() }
                    guard !completed else { return }
                    completed = true
                    self?.releaseInFlight(kind)
                    resultsLock.lock()
                    results[kind] = result
                    resultsLock.unlock()
                    group.leave()
                }

                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + expensiveTimeout) {
                    fireOnce(.skipped(reason: "expensive handler timeout (\(Int(expensiveTimeout))s)"))
                }

                handlerType.sync(context: context, timeout: expensiveTimeout) { result in
                    fireOnce(result)
                }
            }

            group.notify(queue: .global(qos: .userInitiated)) {
                // Aggregate: success wins, then failure, else skipped.
                let aggregated: SyncResult = {
                    if results.values.contains(where: { if case .success = $0 { return true } else { return false } }) {
                        return .success
                    }
                    if let failure = results.values.first(where: { if case .failure = $0 { return true } else { return false } }) {
                        return failure
                    }
                    return .skipped(reason: "no handler produced success")
                }()
                completion?(aggregated)
            }
        }
    }

    // MARK: - Reentrancy
    private func claimInFlight(_ kind: WidgetSyncKind, reason: SyncReason) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if inFlight.contains(kind) {
            pendingResync[kind] = reason
            return false
        }
        inFlight.insert(kind)
        return true
    }

    private func releaseInFlight(_ kind: WidgetSyncKind) {
        lock.lock()
        let pending = pendingResync.removeValue(forKey: kind)
        inFlight.remove(kind)
        lock.unlock()
        if let pending {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.sync(kinds: [kind], reason: pending)
            }
        }
    }

    // MARK: - Context helpers
    // Scope is captured by the caller (on main) and passed in; the Keychain nonce read runs here, off main.
    func currentContext(scopeId: String, reason: SyncReason) -> WidgetSyncContext {
        let nonce: String
        if let existing = KeychainHelper.shared.read(key: .widgetSessionNonce) {
            nonce = existing
        } else {
            let new = UUID().uuidString
            KeychainHelper.shared.save(key: .widgetSessionNonce, value: new)
            nonce = new
        }

        return WidgetSyncContext(
            scopeId: scopeId,
            sessionNonce: nonce,
            language: LanguageHelper.selectedLanguage,
            theme: UserDefaultsWrapper.selected_theme,
            isPro: false,
            reason: reason
        )
    }
}
