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
        case lifecycle    = "LIFECYCLE"
        case iap          = "IAP"
        case network      = "NETWORK"
        case remoteConfig = "RemoteConfig"
        case firestore    = "Firestore"
        case keychain     = "Keychain"
        case notification = "Notification"
        case tracking     = "Tracking"
        case location     = "Location"
        case supabase     = "Supabase"
        case push         = "Push"
    }

    static var enabledTypes: Set<LogType> = [.general, .lifecycle, .iap, .network, .remoteConfig, .supabase, .push, .location]
    static var showTimestamp: Bool = true

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    static func log(
        _ level: LogLevel = .info,
        _ type: LogType = .general,
        _ message: String,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        guard enabledTypes.contains(type) else { return }

        let filename = (file as NSString).lastPathComponent
        let timestamp = showTimestamp ? "[\(timestampFormatter.string(from: Date()))] " : ""
        let fullMessage = "\(timestamp)\(level.rawValue)\(type.rawValue): \(message) (\(filename):\(line)) -> \(function)"

        debugPrint(fullMessage)
    }
}

@inline(__always)
func log(
    _ level: LogLevel = .info,
    _ type: Logger.LogType = .general,
    _ message: String,
    file: String = #fileID,
    line: Int = #line,
    function: String = #function
) {
    Logger.log(level, type, message, file: file, line: line, function: function)
}
