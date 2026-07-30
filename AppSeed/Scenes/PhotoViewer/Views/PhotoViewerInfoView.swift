//
//  PhotoViewerInfoView.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import SnapKit

final class PhotoViewerInfoView: UIView {

    // MARK: - UI
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .white
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 15, fontWeight: .semibold, textColor: .white)
        label.numberOfLines = 1
        return label
    }()

    private lazy var titleRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .center
        return stack
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .medium, textColor: UIColor.white.withAlphaComponent(0.7))
        label.numberOfLines = 1
        return label
    }()

    private lazy var bodyLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 14, fontWeight: .regular, textColor: UIColor.white.withAlphaComponent(0.85))
        label.numberOfLines = 1
        return label
    }()

    private lazy var chevronIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let view = UIImageView(image: UIImage(systemName: Symbols.chevron_down.symbolName, withConfiguration: config))
        view.tintColor = UIColor.white.withAlphaComponent(0.5)
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleRow, subtitleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    // MARK: - Properties
    private var isExpanded = false
    private var hasOverflow = false

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with info: PhotoViewerInfo) {
        if let icon = info.icon {
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            iconView.image = UIImage(systemName: icon, withConfiguration: config)
        }
        iconView.isHidden = info.icon == nil

        titleLabel.text = info.title
        titleRow.isHidden = info.title.isEmpty

        subtitleLabel.text = info.subtitle
        subtitleLabel.isHidden = info.subtitle.isEmpty

        bodyLabel.text = info.body
        bodyLabel.isHidden = info.body.isEmpty
    }

    // MARK: - Life Cycle
    // Whether the body overflows one line is only knowable once the label has a width.
    override func layoutSubviews() {
        super.layoutSubviews()
        updateOverflowState()
    }

    // MARK: - Actions
    @objc private func toggleExpand() {
        guard hasOverflow else { return }
        isExpanded.toggle()

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.bodyLabel.numberOfLines = self.isExpanded ? 0 : 1
            self.chevronIcon.transform = self.isExpanded
                ? CGAffineTransform(rotationAngle: .pi)
                : .identity
            self.superview?.layoutIfNeeded()
        }
    }

    // MARK: - Private
    private func updateOverflowState() {
        guard let text = bodyLabel.text, text.isNotEmpty, bodyLabel.bounds.width > 0 else {
            chevronIcon.isHidden = true
            return
        }

        let font = bodyLabel.font ?? .systemFont(ofSize: 14)
        let textHeight = text.height(withConstrainedWidth: bodyLabel.bounds.width, font: font)
        hasOverflow = textHeight > font.lineHeight + 2
        chevronIcon.isHidden = !hasOverflow
    }
}

// MARK: - Draw
extension PhotoViewerInfoView {
    private func draw() {
        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        layer.cornerRadius = 14
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        addSubview(contentStack)
        addSubview(chevronIcon)

        contentStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(chevronIcon.snp.leading).offset(-8)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
        }

        iconView.snp.makeConstraints {
            $0.width.equalTo(14)
        }

        chevronIcon.snp.makeConstraints {
            $0.width.height.equalTo(14)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(contentStack.snp.top).offset(10)
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleExpand)))
    }
}
