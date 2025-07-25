import Foundation

enum LogLevel: String {
    case success = "✅"
    case info    = "ℹ️"
    case warning = "⚠️"
    case error   = "❌"
}

struct Logger {
    enum LogType: String {
        case general      = "GENERAL"
        case iap          = "IAP"
        case network      = "NETWORK"
        case remoteConfig = "RemoteConfig"
        case firestore    = "Firestore"
        case keychain     = "Keychain"
        case notification = "Notification"
        case tracking     = "Tracking"
    }

    static var enabledTypes: Set<LogType> = [.general, .iap, .network, .remoteConfig]
    static var showTimestamp: Bool = true

    static func log(
        _ level: LogLevel = .info,
        _ type: LogType = .general,
        _ message: String
    ) {
        guard enabledTypes.contains(type) else { return }

        let filename = (#file as NSString).lastPathComponent
        let timestamp = showTimestamp ? "[\(timestampString())] " : ""
        let fullMessage = "\(timestamp)\(level.rawValue)\(type.rawValue): \(message) (\(filename):\(#line)) -> \(#function)"

        debugPrint(fullMessage)
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}

@inline(__always)
func log(
    _ level: LogLevel = .info,
    _ type: Logger.LogType = .general,
    _ message: String
) {
    Logger.log(level, type, message)
}
