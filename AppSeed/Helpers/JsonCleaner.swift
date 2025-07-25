//
//  JsonCleaner.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

public struct JsonClener {
    static func clean(_ raw: String?) -> String? {
        return raw?.cleanedJsonString()
    }
}

public extension String {
    func cleanedJsonString() -> String {
        var cleaned = self
        if cleaned.hasPrefix("```json") || cleaned.hasPrefix("```") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        }
        cleaned = cleaned.replacingOccurrences(of: "\\", with: "")

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
