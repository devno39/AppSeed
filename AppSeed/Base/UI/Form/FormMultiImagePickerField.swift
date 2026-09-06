//
//  FormMultiImagePickerField.swift
//  AppSeed
//
//  Created by Claude on 27.03.2026.
//

import UIKit
import SnapKit

final class FormMultiImagePickerField: UIView {

    // MARK: - Constants
    private let thumbnailSize: CGFloat = 96
    private let deleteButtonSize: CGFloat = 24
    private let maxImages: Int

    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private lazy var addButton: UIView = {
        let container = UIView()
        container.backgroundColor = ColorBackground.backgroundSecondary.color
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 2
        container.setBorderColor(ColorBackground.backgroundBorder.color)

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let icon = UIImageView(image: UIImage(systemName: Symbols.plus.symbolName, withConfiguration: config))
        icon.tintColor = ColorText.textSecondary.color
        icon.contentMode = .center
        container.addSubview(icon)
        icon.snp.makeConstraints { $0.center.equalToSuperview() }

        let tap = UITapGestureRecognizer(target: self, action: #selector(addTapped))
        container.addGestureRecognizer(tap)
        return container
    }()

    // MARK: - Properties
    private(set) var images: [UIImage] = []

    // MARK: - Closure
    var onTap: EmptyClosure?
    var onImagesChanged: AnyClosure<[UIImage]>?

    // MARK: - Init
    init(maxImages: Int = 5) {
        self.maxImages = maxImages
        super.init(frame: .zero)
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setImages(_ newImages: [UIImage]) {
        images = Array(newImages.prefix(maxImages))
        rebuildThumbnails()
        onImagesChanged?(images)
    }

    func addImages(_ newImages: [UIImage]) {
        let remaining = maxImages - images.count
        guard remaining > 0 else { return }
        images.append(contentsOf: newImages.prefix(remaining))
        rebuildThumbnails()
        onImagesChanged?(images)
    }

    // MARK: - Actions
    @objc private func addTapped() {
        onTap?()
    }

    // MARK: - Private
    private func rebuildThumbnails() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, image) in images.enumerated() {
            let container = UIView()
            container.snp.makeConstraints { $0.width.height.equalTo(thumbnailSize) }

            let iv = UIImageView(image: image)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 12
            container.addSubview(iv)
            iv.snp.makeConstraints { $0.edges.equalToSuperview() }

            let deleteButton = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
            deleteButton.setImage(UIImage(systemName: Symbols.minus.symbolName, withConfiguration: config), for: .normal)
            deleteButton.tintColor = ColorText.textPrimary.color
            deleteButton.backgroundColor = ColorBackground.backgroundSecondary.color
            deleteButton.layer.cornerRadius = deleteButtonSize / 2
            deleteButton.tag = index
            deleteButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
            container.addSubview(deleteButton)
            deleteButton.snp.makeConstraints {
                $0.top.equalToSuperview().offset(-4)
                $0.trailing.equalToSuperview().offset(4)
                $0.width.height.equalTo(deleteButtonSize)
            }

            stackView.addArrangedSubview(container)
        }

        addButton.isHidden = images.count >= maxImages
        if !addButton.isHidden {
            stackView.addArrangedSubview(addButton)
        }
    }

    @objc private func deleteTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < images.count else { return }
        images.remove(at: index)
        rebuildThumbnails()
        onImagesChanged?(images)
    }
}

// MARK: - Draw
extension FormMultiImagePickerField {
    private func draw() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.clipsToBounds = false
        clipsToBounds = false

        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(4)
            $0.height.equalTo(thumbnailSize)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        addButton.snp.makeConstraints {
            $0.width.height.equalTo(thumbnailSize)
        }

        stackView.addArrangedSubview(addButton)
    }
}
