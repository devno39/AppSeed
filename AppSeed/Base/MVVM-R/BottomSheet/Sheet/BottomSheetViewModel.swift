//
//  BottomSheetViewModel.swift
//  AppSeed
//
//  Created by Codex on 22.02.2026.
//

import Foundation
import UIKit

// MARK: - Action Model
struct BottomSheetAction {

    // MARK: - Style
    enum Style {
        case normal
        case selectable
    }

    let id: String
    let title: String
    let subtitle: String?
    let icon: String?
    let emoji: String?     // fills the icon circle instead of an SF symbol
    let style: Style
    let isEnabled: Bool
    let isSelected: Bool
    let handler: EmptyClosure?

    init(id: String = UUID().uuidString, title: String, subtitle: String? = nil, icon: String? = nil, emoji: String? = nil, style: Style = .normal, isEnabled: Bool = true, isSelected: Bool = false, handler: EmptyClosure? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.emoji = emoji
        self.style = style
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        self.handler = handler
    }
}

// MARK: - Button Model
struct BottomSheetButton {
    let title: String
    let style: BaseButton.Style
    let handler: EmptyClosure?

    init(title: String, style: BaseButton.Style = .primary, handler: EmptyClosure? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

// MARK: - Source
protocol BottomSheetViewModelDataSource {
    var sheetTitle: String? { get set }
    var sheetSubtitle: String? { get set }
    var actions: [BottomSheetAction] { get set }
    var button: BottomSheetButton? { get set }
    var customView: UIView? { get set }
    var cornerRadius: CGFloat { get }
    var prefersGrabberVisible: Bool { get }
    var dismissesOnActionTap: Bool { get }
}

// MARK: - Closure
protocol BottomSheetViewModelClosureSource {
    var onDismiss: EmptyClosure? { get set }
}

// MARK: - Function
protocol BottomSheetViewModelFunctionSource {}

// MARK: - Protocol
protocol BottomSheetViewModelProtocol: BaseViewModelProtocol, BottomSheetViewModelDataSource, BottomSheetViewModelClosureSource, BottomSheetViewModelFunctionSource {}

// MARK: - ViewModel
class BottomSheetViewModel: BaseViewModel, BottomSheetViewModelProtocol {
    // MARK: - Source
    var sheetTitle: String?
    var sheetSubtitle: String?
    var actions: [BottomSheetAction] = []
    var button: BottomSheetButton?
    var customView: UIView?
    var cornerRadius: CGFloat { 24 }
    var prefersGrabberVisible: Bool { false }
    var dismissesOnActionTap: Bool = true

    // MARK: - Closure
    var onDismiss: EmptyClosure?
}
