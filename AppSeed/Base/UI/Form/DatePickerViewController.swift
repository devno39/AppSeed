//
//  DatePickerViewController.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit
import SnapKit

final class DatePickerViewController: UIViewController {

    // MARK: - UI
    private lazy var calendarView: UICalendarView = {
        let view = UICalendarView()
        view.tintColor = Palette.palette1.color
        view.locale = .current
        view.delegate = self
        view.selectionBehavior = selection
        return view
    }()

    private lazy var pointerLabel: UILabel = {
        let label = UILabel()
        label.text = "👇"
        label.font = .systemFont(ofSize: 20)
        label.isHidden = true
        return label
    }()

    private lazy var doneButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.setTitle(Localizable.ok, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties
    private let initialDate: Date?
    private let onSelect: (Date) -> Void
    private lazy var selection = UICalendarSelectionSingleDate(delegate: self)
    private var selectedDate: Date?
    private var wheelMonitorTimer: Timer?

    // MARK: - Init
    init(date: Date? = nil, onSelect: @escaping (Date) -> Void) {
        self.initialDate = date
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
        preselectInitialDate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startWheelMonitor()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wheelMonitorTimer?.invalidate()
        wheelMonitorTimer = nil
    }

    // MARK: - Private
    private func preselectInitialDate() {
        guard let initialDate else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: initialDate)
        selection.setSelected(components, animated: false)
        selectedDate = initialDate
        doneButton.isEnabled = true
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        guard let date = selectedDate else { return }
        onSelect(date)
        dismiss(animated: true)
    }

    // MARK: - Pointer
    // UICalendarView embeds its month/year wheel privately; no public API exposes the state,
    // so we scan the subview tree for UIPickerView (present → open, absent → closed).
    private func startWheelMonitor() {
        wheelMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.updatePointerVisibility()
        }
    }

    private func updatePointerVisibility() {
        let wheelOpen = findPickerView(in: calendarView) != nil
        if wheelOpen && pointerLabel.isHidden {
            pointerLabel.isHidden = false
            startPointerWiggle()
        } else if !wheelOpen && !pointerLabel.isHidden {
            pointerLabel.layer.removeAllAnimations()
            pointerLabel.transform = .identity
            pointerLabel.isHidden = true
        }
    }

    private func findPickerView(in view: UIView) -> UIPickerView? {
        if let picker = view as? UIPickerView { return picker }
        for sub in view.subviews {
            if let found = findPickerView(in: sub) { return found }
        }
        return nil
    }

    private func startPointerWiggle() {
        pointerLabel.layer.removeAllAnimations()
        pointerLabel.transform = .identity
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]
        ) { [weak self] in
            self?.pointerLabel.transform = CGAffineTransform(translationX: 0, y: 8)
        }
    }
}

// MARK: - UICalendarViewDelegate
extension DatePickerViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        guard let selected = selection.selectedDate else {
            doneButton.isEnabled = false
            return
        }
        let visible = calendarView.visibleDateComponents
        let sameMonth = selected.year == visible.year && selected.month == visible.month
        doneButton.isEnabled = sameMonth
    }
}

// MARK: - UICalendarSelectionSingleDateDelegate
extension DatePickerViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let components = dateComponents,
              let date = Calendar.current.date(from: components) else {
            selectedDate = nil
            doneButton.isEnabled = false
            return
        }
        selectedDate = date
        doneButton.isEnabled = true
    }
}

// MARK: - Draw
extension DatePickerViewController {
    private func draw() {
        view.addSubview(calendarView)
        view.addSubview(pointerLabel)
        view.addSubview(doneButton)

        calendarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.lessThanOrEqualTo(doneButton.snp.top).offset(-16)
        }
        pointerLabel.snp.makeConstraints {
            $0.leading.equalTo(calendarView.snp.leading).offset(20)
            $0.bottom.equalTo(calendarView.snp.top).offset(12)
        }

        doneButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(50)
        }
    }
}
