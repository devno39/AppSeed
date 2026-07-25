//
//  FeedbackHelper.swift
//  AppSeed
//
//  Created by Claude on 24.03.2026.
//

import UIKit

final class FeedbackHelper {
    static let shared = FeedbackHelper()

    private init() {}

    // MARK: - Config
    // The client only POSTs free-text to an edge function; any bot token / chat id / channel
    // secret lives server-side in that function, never in the app bundle.
    private static let feedbackFunctionURL = "https://YOUR_PROJECT.functions.supabase.co/feedback"
    private static let feedbackAuthToken = "YOUR_EDGE_FUNCTION_ANON_KEY"

    // MARK: - Send
    func sendFeedback(message: String, completion: BoolClosure? = nil) {
        guard let url = URL(string: Self.feedbackFunctionURL) else {
            completion?(false)
            return
        }

        let text = formatMessage(message: message)
        let payload: [String: Any] = ["text": text, "parse_mode": "HTML"]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Self.feedbackAuthToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { _, response, error in
            let success = error == nil && (response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } ?? false
            if success {
                log(.info, .network, "Feedback sent")
            } else {
                log(.error, .network, "Feedback send failed: \(error?.localizedDescription ?? "bad status")")
            }
            DispatchQueue.main.async { completion?(success) }
        }.resume()
    }

    // MARK: - Format
    private func formatMessage(message: String) -> String {
        let date = DateHelper.shared.dateString(from: Date(), format: .dayDotMonthDotYear)
        let timeZone = TimeZone.current.identifier
        let device = UIDevice.modelName
        let osVersion = UIDevice.current.systemVersion
        let appVersion = UIApplication.appVersion
        let appBuild = UIApplication.appBuild
        let locale = Locale.current.identifier
        let language = LanguageManager.shared.currentLanguage.rawValue
        let escapedMessage = escapeHTML(message)

        return """
        💬 <b>Feedback</b>

        📅 <b>Date:</b> \(date)
        🕐 <b>TZ:</b> \(timeZone)
        📱 <b>Device:</b> \(device) · iOS \(osVersion)
        📦 <b>App:</b> v\(appVersion) (\(appBuild))
        🌍 <b>Locale:</b> \(locale) · \(language)

        💭 <b>Message:</b>
        \(escapedMessage)
        """
    }

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
