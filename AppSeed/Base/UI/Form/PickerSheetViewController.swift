//
//  PickerSheetViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

// The single wheels-sheet chrome behind FormPickerField: option list or time of day.
// onSelect reports the option index or minutes from midnight respectively.
final class PickerSheetViewController: UIViewController {

    // MARK: - Mode
    enum Mode {
        case options([String], selectedIndex: Int)
        case time(minutesFromMidnight: Int)
    }

    // MARK: - UI
    private lazy var optionPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()

    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = .current
        return picker
    }()

    private lazy var doneButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.setTitle(Localizable.ok, for: .normal)
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties
    private let mode: Mode
    private let onSelect: AnyClosure<Int>

    // MARK: - Init
    init(mode: Mode, onSelect: @escaping AnyClosure<Int>) {
        self.mode = mode
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        draw()
        preselect()
    }

    // MARK: - Private
    private func preselect() {
        switch mode {
        case .options(let options, let selectedIndex):
            guard options.indices.contains(selectedIndex) else { return }
            optionPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
        case .time(let minutes):
            var components = DateComponents()
            components.hour = minutes / 60
            components.minute = minutes % 60
            if let date = Calendar.current.date(from: components) {
                timePicker.date = date
            }
        }
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        let value: Int
        switch mode {
        case .options:
            value = optionPicker.selectedRow(inComponent: 0)
        case .time:
            let components = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
            value = (components.hour ?? 12) * 60 + (components.minute ?? 0)
        }
        dismiss(animated: true) { [onSelect] in
            onSelect(value)
        }
    }
}

// MARK: - UIPickerViewDataSource
extension PickerSheetViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard case .options(let options, _) = mode else { return 0 }
        return options.count
    }
}

// MARK: - UIPickerViewDelegate
extension PickerSheetViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard case .options(let options, _) = mode, options.indices.contains(row) else { return nil }
        return NSAttributedString(
            string: options[row],
            attributes: [.foregroundColor: ColorText.textPrimary.color]
        )
    }
}

// MARK: - Draw
extension PickerSheetViewController {
    private func draw() {
        let picker: UIView
        switch mode {
        case .options: picker = optionPicker
        case .time: picker = timePicker
        }

        view.addSubview(picker)
        view.addSubview(doneButton)

        picker.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(216)
        }

        doneButton.snp.makeConstraints {
            $0.top.equalTo(picker.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
    }
}
