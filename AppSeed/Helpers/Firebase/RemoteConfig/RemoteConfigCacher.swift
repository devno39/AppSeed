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
        static func boolKey(_ k: RemoteConfigHelper.RemoteConfigKeys) -> String { "rc.bool.\(k.rawValue)" }
        static func intKey(_  k: RemoteConfigHelper.RemoteConfigKeys)  -> String { "rc.int.\(k.rawValue)" }
        static func strKey(_  k: RemoteConfigHelper.RemoteConfigKeys)  -> String { "rc.str.\(k.rawValue)" }
    }
    
    // SET
    func rcSet(_ value: Bool,   for key: RemoteConfigHelper.RemoteConfigKeys) { set(value, forKey: RCStore.boolKey(key)) }
    func rcSet(_ value: Int,    for key: RemoteConfigHelper.RemoteConfigKeys) { set(value, forKey: RCStore.intKey(key))  }
    func rcSet(_ value: String, for key: RemoteConfigHelper.RemoteConfigKeys) { set(value, forKey: RCStore.strKey(key))  }
    
    // GET
    func rcGet<T>(for key: RemoteConfigHelper.RemoteConfigKeys, as type: T.Type = T.self) -> T? {
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
    private let stateQueue = DispatchQueue(label: "rc.cacher.state")
    
    // MARK: App Launch
    func cache(completion: BoolClosure? = nil) {
        populateFromRemoteConfig(completion: completion)
    }
    
    // MARK: RC -> Cache (listeleri burada yönet)
    private func populateFromRemoteConfig(completion: BoolClosure?) {
        var ok = true
        let group = DispatchGroup()
        
        // --- String Keys ---
        let stringKeys: [RemoteConfigHelper.RemoteConfigKeys] = [
            .gptKey,
            .gpt_model_free,
            .gpt_model_premium,
            .replicateKey,
            .falaiKey,
            .minimum_supported_version
        ]
        
        // --- Bool Keys ---
        let boolKeys: [RemoteConfigHelper.RemoteConfigKeys] = [
            // .some_feature_flag
        ]
        
        // --- Int Keys ---
        let intKeys: [RemoteConfigHelper.RemoteConfigKeys] = [
            // .limit_free   // RemoteConfigKeys'e eklediğinde burayı aç
        ]
        
        // String fetch
        for key in stringKeys {
            group.enter()
            RemoteConfigHelper.shared.getValue(forKey: key, as: String.self) { [weak self] value in
                defer { group.leave() }
                guard let self else { return }
                if let v = value { self.ud.rcSet(v, for: key) }
                else { self.markFail(&ok, key: key, type: "String") }
            }
        }
        
        // Bool fetch
        for key in boolKeys {
            group.enter()
            RemoteConfigHelper.shared.getValue(forKey: key, as: Bool.self) { [weak self] value in
                defer { group.leave() }
                guard let self else { return }
                if let v = value { self.ud.rcSet(v, for: key) }
                else { self.markFail(&ok, key: key, type: "Bool") }
            }
        }
        
        // Int fetch
        for key in intKeys {
            group.enter()
            RemoteConfigHelper.shared.getValue(forKey: key, as: Int.self) { [weak self] value in
                defer { group.leave() }
                guard let self else { return }
                if let v = value { self.ud.rcSet(v, for: key) }
                else { self.markFail(&ok, key: key, type: "Int") }
            }
        }
        
        group.notify(queue: .main) { completion?(ok) }
    }
    
    private func markFail(_ flag: inout Bool, key: RemoteConfigHelper.RemoteConfigKeys, type: String) {
        stateQueue.sync { flag = false }
        log(.error, .remoteConfig, "\(type) fetch failed for key: \(key.rawValue)")
    }
    
    // MARK: - GET
    ///   let model: String = RemoteConfigCacher.shared.getCached(key: .gpt_model_free) ?? "gpt-4o"
    ///   let limit: Int    = RemoteConfigCacher.shared.getCached(key: .limit_free) ?? 100
    ///   let flag: Bool    = RemoteConfigCacher.shared.getCached(key: .some_feature_flag) ?? false
    func getCached<T>(key: RemoteConfigHelper.RemoteConfigKeys, as type: T.Type = T.self) -> T? {
        ud.rcGet(for: key, as: T.self)
    }
}
