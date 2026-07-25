//
//  FormDatePickerField.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit
import SnapKit

final class FormDatePickerField: UIView {

    // MARK: - UI
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .semibold, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var dateLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 16, fontWeight: .regular, textColor: ColorText.textPrimary.color)
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var calendarIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = ColorText.textSecondary.color
        view.isUserInteractionEnabled = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        view.image = UIImage(systemName: Symbols.calendar.symbolName, withConfiguration: config)
        return view
    }()

    // MARK: - Properties
    private var selectedDate: Date?
    private let placeholder: String?

    // MARK: - Closure
    var onDateChange: AnyClosure<Date>?

    // MARK: - Init
    init(title: String, placeholder: String? = nil, date: Date? = nil) {
        self.selectedDate = date
        self.placeholder = placeholder
        super.init(frame: .zero)
        titleLabel.text = title
        updateDateLabel()
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setDate(_ date: Date?) {
        selectedDate = date
        updateDateLabel()
    }

    // MARK: - Actions
    @objc private func containerTapped() {
        guard let vc = findViewController() else { return }

        let pickerVC = DatePickerViewController(date: selectedDate) { [weak self] date in
            guard let self else { return }
            self.selectedDate = date
            self.updateDateLabel()
            self.onDateChange?(date)
        }

        if let sheet = pickerVC.sheetPresentationController {
            let detent = UISheetPresentationController.Detent.custom { _ in 480 }
            sheet.detents = [detent]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }

        vc.present(pickerVC, animated: true)
    }

    // MARK: - Private
    private func updateDateLabel() {
        if let date = selectedDate {
            dateLabel.text = DateHelper.shared.dateString(
                from: date,
                format: .dayMonthYear,
                locale: .current
            )
            dateLabel.textColor = ColorText.textPrimary.color
        } else {
            dateLabel.text = placeholder
            dateLabel.textColor = ColorText.textSecondary.color.withAlphaComponent(0.5)
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
extension FormDatePickerField {
    private func draw() {
        addSubview(titleLabel)
        addSubview(containerView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(calendarIcon)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }

        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        calendarIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
}
