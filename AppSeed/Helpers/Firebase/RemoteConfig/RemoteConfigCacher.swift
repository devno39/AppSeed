//
//  RemoteConfigCacher.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import FirebaseRemoteConfig

// MARK: - UserDefaults RC helpers
extension UserDefaults {
    private enum RCStore {
        static func boolKey(_ k: RemoteConfigKeys) -> String { "rc.bool.\(k.rawValue)" }
        static func intKey(_  k: RemoteConfigKeys)  -> String { "rc.int.\(k.rawValue)" }
        static func strKey(_  k: RemoteConfigKeys)  -> String { "rc.str.\(k.rawValue)" }
    }

    // SET
    func rcSet(_ value: Bool,   for key: RemoteConfigKeys) { set(value, forKey: RCStore.boolKey(key)) }
    func rcSet(_ value: Int,    for key: RemoteConfigKeys) { set(value, forKey: RCStore.intKey(key))  }
    func rcSet(_ value: String, for key: RemoteConfigKeys) { set(value, forKey: RCStore.strKey(key))  }

    // GET
    func rcGet<T>(for key: RemoteConfigKeys, as type: T.Type = T.self) -> T? {
        switch T.self {
        case is Bool.Type:
            return (object(forKey: RCStore.boolKey(key)) as? Bool) as? T
        case is Int.Type:
            return (object(forKey: RCStore.intKey(key)) as? Int) as? T
        case is String.Type:
            return (string(forKey: RCStore.strKey(key))) as? T
        default:
            assertionFailure("Unsupported RC cached type: \(T.self)")
            return nil
        }
    }
}

// MARK: - RemoteConfigCacher
final class RemoteConfigCacher {
    static let shared = RemoteConfigCacher()

    private init() {}

    private let ud = UserDefaults.standard

    // Cached keys — add new keys here; type comes from expectedType.
    private let cachedKeys: [RemoteConfigKeys] = [
        .gptKey,
        .gpt_model_free,
        .gpt_model_premium,
        .replicateKey,
        .falaiKey,
        .minimum_supported_version
    ]

    // MARK: - Cache
    func cache(completion: BoolClosure? = nil) {
        let group = DispatchGroup()
        var failed = false

        for key in cachedKeys {
            group.enter()
            fetchAndStore(key: key) { success in
                if !success { failed = true }
                group.leave()
            }
        }

        group.notify(queue: .main) { completion?(!failed) }
    }

    // MARK: - GET
    func getCached<T>(key: RemoteConfigKeys, as type: T.Type = T.self) -> T? {
        ud.rcGet(for: key, as: T.self)
    }

    // MARK: - Private
    private func fetchAndStore(key: RemoteConfigKeys, completion: BoolClosure?) {
        switch key.expectedType {
        case is String.Type:
            RemoteConfigHelper.shared.getValue(forKey: key, as: String.self) { [weak self] value in
                guard let self, let value else {
                    log(.error, .remoteConfig, "Fetch failed: \(key.rawValue)")
                    completion?(false)
                    return
                }
                self.ud.rcSet(value, for: key)
                completion?(true)
            }

        case is Bool.Type:
            RemoteConfigHelper.shared.getValue(forKey: key, as: Bool.self) { [weak self] value in
                guard let self, let value else {
                    log(.error, .remoteConfig, "Fetch failed: \(key.rawValue)")
                    completion?(false)
                    return
                }
                self.ud.rcSet(value, for: key)
                completion?(true)
            }

        case is Int.Type:
            RemoteConfigHelper.shared.getValue(forKey: key, as: Int.self) { [weak self] value in
                guard let self, let value else {
                    log(.error, .remoteConfig, "Fetch failed: \(key.rawValue)")
                    completion?(false)
                    return
                }
                self.ud.rcSet(value, for: key)
                completion?(true)
            }

        default:
            log(.error, .remoteConfig, "Unsupported type: \(key.rawValue)")
            completion?(false)
        }
    }
}
