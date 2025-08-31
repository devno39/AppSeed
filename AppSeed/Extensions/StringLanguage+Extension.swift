//
//  StringLanguage+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import NaturalLanguage

public extension String {
    func detectLanguage() -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        return recognizer.dominantLanguage?.rawValue
    }

    func displayNameForLanguage() -> String {
        let locale = Locale.current
        return locale.localizedString(forLanguageCode: self) ?? self
    }
}
