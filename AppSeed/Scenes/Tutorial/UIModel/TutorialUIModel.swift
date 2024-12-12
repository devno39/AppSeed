//
//  TutorialUIModel.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import Foundation

struct TutorialUIModel {
    let image: TutorialImage?
    let title: String?
    let subtitle: String?
}

// MARK: - Models
extension TutorialUIModel {
    static func getTutorialData() -> [TutorialUIModel] {
        let models = [
            TutorialUIModel(
                image: .tutorial_1,
                title: TutorialLocalizable.tutorial_title_1,
                subtitle: TutorialLocalizable.tutorial_subtitle_1
            ),
            TutorialUIModel(
                image: .tutorial_2,
                title: TutorialLocalizable.tutorial_title_2,
                subtitle: TutorialLocalizable.tutorial_subtitle_2
            ),
            TutorialUIModel(
                image: .tutorial_3,
                title: TutorialLocalizable.tutorial_title_3,
                subtitle: TutorialLocalizable.tutorial_subtitle_3
            )
        ]
        
        return models
    }
}
