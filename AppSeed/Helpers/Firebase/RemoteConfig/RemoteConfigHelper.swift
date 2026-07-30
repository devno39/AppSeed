//
//  RemoteConfigHelper.swift
//  AppSeed
//
//  Created by tunay alver on 12.07.2025.
//

import FirebaseRemoteConfig

final class RemoteConfigHelper {
    static let shared = RemoteConfigHelper()
    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = .zero
        remoteConfig.configSettings = settings
    }

    func getValue<T>(forKey key: RemoteConfigKeys, as type: T.Type = T.self, completion: AnyClosure<T?>?) {
        remoteConfig.fetchAndActivate { status, error in
            guard status == .successFetchedFromRemote || status == .successUsingPreFetchedData else {
                log(.error, .remoteConfig, "Fetch Failed: \(error?.localizedDescription ?? "Unknown error")")
                completion?(nil)
                return
            }

            let configValue = self.remoteConfig[key.rawValue]
            switch T.self {
            case is String.Type:
                completion?(configValue.stringValue as? T)
            case is Bool.Type:
                completion?(configValue.boolValue as? T)
            case is Int.Type:
                completion?(configValue.numberValue.intValue as? T)
            case is Double.Type:
                completion?(configValue.numberValue.doubleValue as? T)
            default:
                log(.error, .remoteConfig, "Unsupported type requested")
                completion?(nil)
            }
        }
    }
}
