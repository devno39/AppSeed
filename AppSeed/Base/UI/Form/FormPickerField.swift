//
//  FormPickerField.swift
//  AppSeed
//
//  Created by Claude on 30.04.2026.
//

import UIKit
import SnapKit

// One chooser row for forms: small header above, icon on the leading edge, current value
// + chevron trailing, the whole row tappable. Options and time share the same anatomy and
// open the same PickerSheetViewController chrome.
final class FormPickerField: UIView {

    // MARK: - Content
    private enum Content {
        case options
        case time
    }

    // MARK: - UI
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var headerLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .semibold, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = ColorText.textSecondary.color
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var valueLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 15, fontWeight: .medium, textColor: ColorText.textSecondary.color)
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var chevronView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = ColorText.textSecondary.color
        view.isUserInteractionEnabled = false
        view.image = UIImage(systemName: Symbols.chevron_up_chevron_down.symbolName)?
            .applyingSymbolConfiguration(.init(pointSize: 11, weight: .semibold))
        return view
    }()

    // MARK: - Properties
    private let content: Content
    private let icon: String
    private var options: [String]
    private(set) var selectedIndex: Int
    private var minutesFromMidnight: Int

    // MARK: - Closure
    var onSelectionChange: AnyClosure<Int>?
    var onTimeChange: AnyClosure<Int>?

    // MARK: - Init
    init(header: String, icon: String, options: [String], selectedIndex: Int) {
        self.content = .options
        self.icon = icon
        self.options = options
        self.selectedIndex = max(0, min(selectedIndex, options.count - 1))
        self.minutesFromMidnight = 0
        super.init(frame: .zero)
        headerLabel.text = header
        draw()
        updateValueLabel()
    }

    init(header: String, icon: String, minutesFromMidnight: Int) {
        self.content = .time
        self.icon = icon
        self.options = []
        self.selectedIndex = 0
        self.minutesFromMidnight = minutesFromMidnight
        super.init(frame: .zero)
        headerLabel.text = header
        draw()
        updateValueLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setSelectedIndex(_ index: Int) {
        guard index >= 0, index < options.count else { return }
        selectedIndex = index
        updateValueLabel()
    }

    func setOptions(_ options: [String], selectedIndex: Int) {
        self.options = options
        self.selectedIndex = max(0, min(selectedIndex, options.count - 1))
        updateValueLabel()
    }

    func setTime(minutesFromMidnight: Int) {
        self.minutesFromMidnight = minutesFromMidnight
        updateValueLabel()
    }

    // MARK: - Actions
    @objc private func containerTapped() {
        guard let vc = findViewController() else { return }

        let mode: PickerSheetViewController.Mode = switch content {
        case .options: .options(options, selectedIndex: selectedIndex)
        case .time: .time(minutesFromMidnight: minutesFromMidnight)
        }

        let pickerVC = PickerSheetViewController(mode: mode) { [weak self] value in
            guard let self else { return }
            switch self.content {
            case .options:
                self.selectedIndex = value
                self.updateValueLabel()
                self.onSelectionChange?(value)
            case .time:
                self.minutesFromMidnight = value
                self.updateValueLabel()
                self.onTimeChange?(value)
            }
        }

        if let sheet = pickerVC.sheetPresentationController {
            let detent = UISheetPresentationController.Detent.custom { _ in 320 }
            sheet.detents = [detent]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }

        vc.present(pickerVC, animated: true)
    }

    // MARK: - Private
    private func updateValueLabel() {
        switch content {
        case .options:
            valueLabel.text = options.indices.contains(selectedIndex) ? options[selectedIndex] : nil
        case .time:
            var components = DateComponents()
            components.hour = minutesFromMidnight / 60
            components.minute = minutesFromMidnight % 60
            let date = Calendar.current.date(from: components) ?? Date()
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.timeStyle = .short
            valueLabel.text = formatter.string(from: date)
        }
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController { return vc }
            responder = next
        }
        return nil
    }
}

// MARK: - Draw
extension FormPickerField {
    private func draw() {
        addSubview(headerLabel)
        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(chevronView)

        iconView.image = UIImage(systemName: icon)?
            .applyingSymbolConfiguration(.init(pointSize: 16, weight: .medium))

        headerLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(48)
        }

        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        chevronView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints {
            $0.trailing.equalTo(chevronView.snp.leading).offset(-4)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(iconView.snp.trailing).offset(12)
        }
    }
}
