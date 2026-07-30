//
//  PhotoViewerViewModel.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import Foundation

// MARK: - Info Model
struct PhotoViewerInfo {
    let icon: String?
    let title: String?
    let subtitle: String?
    let body: String?

    init(icon: String? = nil, title: String? = nil, subtitle: String? = nil, body: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
}

// MARK: - Source
protocol PhotoViewerViewModelDataSource {
    var imageURLs: [String] { get }
    var startIndex: Int { get }
    var info: PhotoViewerInfo? { get }
    var actions: [BottomSheetAction] { get }
}

// MARK: - Protocol
protocol PhotoViewerViewModelProtocol: BaseViewModelProtocol, PhotoViewerViewModelDataSource { }

// MARK: - ViewModel
final class PhotoViewerViewModel: BaseViewModel, PhotoViewerViewModelProtocol {

    // MARK: - Source
    let imageURLs: [String]
    let startIndex: Int
    let info: PhotoViewerInfo?
    let actions: [BottomSheetAction]

    // MARK: - Init
    init(imageURLs: [String], startIndex: Int, info: PhotoViewerInfo?, actions: [BottomSheetAction]) {
        self.imageURLs = imageURLs
        self.startIndex = startIndex
        self.info = info
        self.actions = actions
        super.init()
    }
}
