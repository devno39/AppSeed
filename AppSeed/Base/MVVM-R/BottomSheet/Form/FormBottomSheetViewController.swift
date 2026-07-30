//
//  FormBottomSheetViewController.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit
import SnapKit

class FormBottomSheetViewController<V: FormBottomSheetViewModelProtocol, R: BaseRouterProtocol>: BaseViewController<V, R> {

    // MARK: - UI
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.palette1.color.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2
        return view
    }()

    private lazy var dragHandleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 18, fontWeight: .bold, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 14, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.textAlignment = .center
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .interactive
        view.contentInsetAdjustmentBehavior = .never
        view.clipsToBounds = false
        return view
    }()

    lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.clipsToBounds = false
        return stack
    }()

    lazy var saveButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties
    override var adjustsScrollForKeyboard: Bool { false }
    private var containerBottom: Constraint?
    private var containerHeight: Constraint?
    private var saveButtonBottom: Constraint?
    private var isDismissing = false
    private var hasAppeared = false
    private var lastCalculatedHeight: CGFloat = 0

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasAppeared {
            hasAppeared = true
            configureContainer()
            animateIn()
        } else {
            updateContainerHeightIfNeeded()
        }
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
        setupKeyboardObserver()
        setupGestures()
    }

    // MARK: - Container
    private func configureContainer() {
        containerView.layer.cornerRadius = viewModel?.cornerRadius ?? 24

        let safeBottom = view.safeAreaInsets.bottom
        saveButtonBottom?.update(offset: -(safeBottom + 16))

        let height = calculateContentHeight()
        lastCalculatedHeight = height
        containerHeight?.update(offset: height)
        view.layoutIfNeeded()

        containerView.transform = CGAffineTransform(translationX: 0, y: height)
    }

    private func updateContainerHeightIfNeeded() {
        let newHeight = calculateContentHeight()
        guard abs(newHeight - lastCalculatedHeight) > 1 else { return }
        lastCalculatedHeight = newHeight
        containerHeight?.update(offset: newHeight)

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func calculateContentHeight() -> CGFloat {
        contentStack.layoutIfNeeded()

        var height: CGFloat = 0
        height += 12 + 4 + 20       // grabber top + grabber height + spacing to title
        height += viewModel?.sheetTitle != nil ? 24 : 0
        height += viewModel?.sheetSubtitle != nil ? 24 : 0
        height += 20                 // spacing to content
        height += contentStack.systemLayoutSizeFitting(
            CGSize(width: UIScreen.main.bounds.width - 32, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        height += 16                 // spacing content → button
        height += 50                 // save button height
        height += 16                 // bottom padding
        height += view.safeAreaInsets.bottom

        let maxHeight = UIScreen.main.bounds.height - view.safeAreaInsets.top - 20
        return min(height, maxHeight)
    }

    // MARK: - Animation
    private func animateIn() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5) {
            self.dimView.alpha = 1
            self.containerView.transform = .identity
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // If a child is presented (e.g. share sheet), let it dismiss normally
        if presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }
        guard flag, !isDismissing else {
            let onDismiss = viewModel?.onDismiss
            super.dismiss(animated: false) {
                completion?()
                onDismiss?()
            }
            return
        }
        isDismissing = true
        view.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.bounds.height)
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }

    // MARK: - Keyboard
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard !isDismissing,
              let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let screenHeight = UIScreen.main.bounds.height
        let kbHeight = screenHeight - frame.origin.y
        let safeBottom = view.safeAreaInsets.bottom
        let effectiveHeight = max(0, kbHeight - safeBottom)
        let clampedHeight = min(effectiveHeight, 260)

        let options = UIView.AnimationOptions(rawValue: curveValue << 16)
        containerBottom?.update(offset: -clampedHeight)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Gestures
    private func setupGestures() {
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        dragHandleView.addGestureRecognizer(pan)
    }

    @objc private func dimTapped() {
        if isKeyboardVisible {
            view.endEditing(true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            let offset = max(0, translation.y)
            containerView.transform = CGAffineTransform(translationX: 0, y: offset)
            let progress = min(offset / 300, 1)
            dimView.alpha = 1 - progress * 0.5
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view)
            if translation.y > 100 || velocity.y > 500 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5) {
                    self.containerView.transform = .identity
                    self.dimView.alpha = 1
                }
            }
        default:
            break
        }
    }

    // MARK: - Public
    func addFormItem(_ view: UIView) {
        contentStack.addArrangedSubview(view)
    }

    func updateSaveButton(enabled: Bool) {
        saveButton.isEnabled = enabled
    }

    // MARK: - Actions
    @objc private func saveButtonTapped() {
        view.endEditing(true)
        viewModel?.onSave?()
    }
}

// MARK: - Draw
extension FormBottomSheetViewController {
    private func draw() {
        view.addSubview(dimView)
        view.addSubview(containerView)
        containerView.addSubview(grabberView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(dragHandleView)
        containerView.addSubview(scrollView)
        containerView.addSubview(saveButton)
        scrollView.addSubview(contentStack)

        // Dim
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Container
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            containerBottom = $0.bottom.equalToSuperview().constraint
            containerHeight = $0.height.equalTo(400).constraint
        }

        // Grabber
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(36)
            $0.height.equalTo(4)
        }

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(grabberView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        // Drag handle (covers grabber + title + subtitle for pan gesture)
        dragHandleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(subtitleLabel.snp.bottom).offset(10)
        }

        // Save button
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            saveButtonBottom = $0.bottom.equalToSuperview().offset(-50).constraint
            $0.height.equalTo(50)
        }

        // Scroll view
        scrollView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }

        // Content stack
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            $0.width.equalToSuperview().offset(-32)
        }

        // Bind content
        titleLabel.text = viewModel?.sheetTitle
        subtitleLabel.text = viewModel?.sheetSubtitle
        titleLabel.isHidden = viewModel?.sheetTitle == nil
        subtitleLabel.isHidden = viewModel?.sheetSubtitle == nil
        saveButton.setTitle(viewModel?.saveTitle, for: .normal)
    }
}
