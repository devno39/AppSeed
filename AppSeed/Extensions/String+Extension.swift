//
//  String+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import UIKit

extension String {
    func htmlAttributedString(
        font: UIFont = .systemFont(ofSize: 15),
        color: UIColor = .label
    ) -> NSAttributedString? {
        let css = """
        <style>
        body {
            font-family: -apple-system, sans-serif;
            font-size: \(font.pointSize)px;
            color: \(color.cssRGBA);
            line-height: 1.5;
        }
        h1 { font-size: \(font.pointSize + 6)px; }
        h2 { font-size: \(font.pointSize + 2)px; }
        </style>
        """
        let html = css + self
        guard let data = html.data(using: .utf8) else { return nil }
        return try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }

    func toPriceDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current

        if let number = formatter.number(from: self) {
            return number.doubleValue
        } else {
            if self.contains("$") {
                formatter.locale = Locale(identifier: "en_US")
            } else if self.contains("€") {
                formatter.locale = Locale(identifier: "de_DE")
            } else if self.contains("₺") {
                formatter.locale = Locale(identifier: "tr_TR")
            }

            if let number = formatter.number(from: self) {
                return number.doubleValue
            }
            return nil
        }
    }

    func getLocale() -> Locale {
        if self.contains("$") {
            return Locale(identifier: "en_US")
        } else if self.contains("€") {
            return Locale(identifier: "de_DE")
        } else if self.contains("₺") {
            return Locale(identifier: "tr_TR")
        }

        return Locale.current
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let boundingBox = (self as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

// MARK: - Date
extension String {

    // Postgres sends microsecond fractions; ISO8601DateFormatter reads at most 3 digits.
    var postgresDate: Date? {
        let trimmed = replacingOccurrences(
            of: #"(\.\d{3})\d+"#,
            with: "$1",
            options: .regularExpression
        )
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return fractional.date(from: trimmed) ?? plain.date(from: trimmed)
    }
}

// MARK: - Emoji
extension String {

    // Per character, not per scalar: ✈️ is U+2708 + VS16 and its base scalar reports
    // isEmojiPresentation == false, so a scalar-wise test calls it text. The presentation check
    // then keeps plain digits out — they carry isEmoji too.
    var isEmojiOnly: Bool {
        guard !isEmpty else { return false }
        return allSatisfy { character in
            guard let first = character.unicodeScalars.first, first.properties.isEmoji else { return false }
            return character.unicodeScalars.count > 1 || first.properties.isEmojiPresentation
        }
    }
}
