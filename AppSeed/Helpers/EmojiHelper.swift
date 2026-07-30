//
//  EmojiHelper.swift
//  AppSeed
//
//  Created by Claude on 29.03.2026.
//

import UIKit

enum EmojiHelper {

    // MARK: - Warmup (call from Splash)
    static func warmup() {
        DispatchQueue.global(qos: .utility).async {
            _ = keywordData
        }
    }

    private static let supportedLanguages: Set<String> = Set(AppLanguage.allCases.map(\.rawValue))

    // MARK: - Suggest (exact word match only)
    static func suggestEmoji(for title: String) -> String? {
        guard isSupportedLanguage else { return nil }

        let query = title.lowercased().trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return nil }

        let words = query.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard !words.isEmpty else { return nil }

        // 1. Multi-word phrase match (longest first)
        for data in keywordData {
            for (phrase, emoji) in data.multiWord where query.contains(phrase) {
                return emoji
            }
        }

        // 2. Exact word match only — no prefix
        for data in keywordData {
            for word in words {
                if let emoji = data.words[word] { return emoji }
            }
        }

        return nil
    }

    // MARK: - Extract or Suggest
    static func resolveEmoji(for title: String, fallback: String? = nil) -> (title: String, emoji: String?) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)

        if let (clean, found) = extractEmoji(from: trimmed) {
            return (clean, found)
        }

        let suggested = suggestEmoji(for: trimmed) ?? fallback
        return (trimmed, suggested)
    }

    private static func extractEmoji(from text: String) -> (String, String)? {
        for character in text {
            guard character.unicodeScalars.first?.properties.isEmoji == true,
                  character.unicodeScalars.first?.properties.isEmojiPresentation == true
                    || character.unicodeScalars.count > 1 else { continue }

            // Skip single-digit numbers (0-9) — they have isEmoji = true
            if character.unicodeScalars.count == 1, character.isASCII { continue }

            let emoji = String(character)
            var cleaned = text
            if let range = cleaned.range(of: emoji) {
                cleaned.removeSubrange(range)
            }
            while cleaned.contains("  ") {
                cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
            }
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
            return (cleaned, emoji)
        }
        return nil
    }

    // MARK: - Language Check
    private static var isSupportedLanguage: Bool {
        guard let keyboard = UITextInputMode.activeInputModes.first,
              let lang = keyboard.primaryLanguage else {
            return false
        }
        let code = String(lang.prefix(2)).lowercased()
        return supportedLanguages.contains(code)
    }

    // MARK: - JSON Data
    private struct KeywordData {
        let multiWord: [(String, String)]
        let words: [String: String]
    }

    private static let keywordData: [KeywordData] = {
        return AppLanguage.allCases.compactMap { loadKeywords(for: $0.rawValue) }
    }()

    private static func loadKeywords(for language: String) -> KeywordData? {
        guard let url = Bundle.main.url(forResource: "emoji_keywords_\(language)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        let multiWordDict = json["multiWord"] as? [String: String] ?? [:]
        let wordsDict = json["words"] as? [String: String] ?? [:]

        let sortedMultiWord = multiWordDict
            .sorted { $0.key.count > $1.key.count }
            .map { ($0.key, $0.value) }

        return KeywordData(
            multiWord: sortedMultiWord,
            words: wordsDict
        )
    }
}
