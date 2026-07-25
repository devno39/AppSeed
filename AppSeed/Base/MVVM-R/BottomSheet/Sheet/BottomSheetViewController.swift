//
//  BottomSheetViewController.swift
//  AppSeed
//
//  Created by Codex on 22.02.2026.
//

import UIKit
import SnapKit

class BottomSheetViewController<V: BottomSheetViewModelProtocol, R: BottomSheetRouter>: BaseViewController<V, R> {

    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = false
        view.showsVerticalScrollIndicator = false
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()

    private lazy var grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.palette1.color.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2
        return view
    }()

    private lazy var grabberContainer: UIView = {
        let container = UIView()
        container.addSubview(grabberView)
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(36)
            $0.height.equalTo(4)
            $0.bottom.equalToSuperview().offset(-12)
        }
        return container
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 18, fontWeight: .bold, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        return label
    }()

    private lazy var titleContainer: UIView = {
        let container = UIView()
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
        return container
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 14, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleContainer: UIView = {
        let container = UIView()
        container.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
        return container
    }()

    private lazy var actionButton: BaseButton = {
        let button = BaseButton()
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonContainer: UIView = {
        let container = UIView()
        container.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }
        return container
    }()

    // MARK: - Properties
    private var actionViews: [BottomSheetActionView] = []
    private var dimView: UIView?
    private var isDismissing = false
    private var hasAppeared = false

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupDim()
        setupContainer()
        setupPanGesture()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasAppeared else { return }
        hasAppeared = true
        configureContainer()
        animateIn()
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
    }

    // MARK: - Setup
    private func setupDim() {
        let dim = UIView()
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dim.alpha = 0
        dim.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimTapped)))
        view.insertSubview(dim, at: 0)
        dim.snp.makeConstraints { $0.edges.equalToSuperview() }
        dimView = dim
    }

    private func setupContainer() {
        scrollView.backgroundColor = ColorBackground.backgroundPrimary.color
        scrollView.layer.cornerRadius = viewModel?.cornerRadius ?? 24
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scrollView.layer.masksToBounds = true
    }

    private func configureContainer() {
        view.layoutIfNeeded()
        let targetSize = contentStack.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let contentHeight = targetSize.height + view.safeAreaInsets.bottom + 8

        scrollView.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(contentHeight)
        }
        view.layoutIfNeeded()
        scrollView.transform = CGAffineTransform(translationX: 0, y: contentHeight)
    }

    // MARK: - Animation
    private func animateIn() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5) {
            self.dimView?.alpha = 1
            self.scrollView.transform = .identity
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
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
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView?.alpha = 0
            self.scrollView.transform = CGAffineTransform(translationX: 0, y: self.scrollView.bounds.height)
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }

    // MARK: - Gestures
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scrollView.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            let offset = max(0, translation.y)
            scrollView.transform = CGAffineTransform(translationX: 0, y: offset)
            let progress = min(offset / 300, 1)
            dimView?.alpha = 1 - progress * 0.5
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view)
            if translation.y > 100 || velocity.y > 500 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5) {
                    self.scrollView.transform = .identity
                    self.dimView?.alpha = 1
                }
            }
        default:
            break
        }
    }

    @objc private func dimTapped() {
        if isKeyboardVisible {
            view.endEditing(true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Actions
    @objc private func actionButtonTapped() {
        let handler = viewModel?.button?.handler
        let onDismiss = viewModel?.onDismiss
        dismiss(animated: true) {
            handler?()
            onDismiss?()
        }
    }

    func reloadActions(_ actions: [BottomSheetAction]) {
        viewModel?.actions = actions
        for (index, action) in actions.enumerated() where index < actionViews.count {
            actionViews[index].configure(with: action)
        }
    }

    private func actionViewTapped(_ action: BottomSheetAction) {
        guard action.isEnabled else { return }
        if viewModel?.dismissesOnActionTap == true {
            let onDismiss = viewModel?.onDismiss
            dismiss(animated: true) {
                action.handler?()
                onDismiss?()
            }
        } else {
            action.handler?()
        }
    }

}

// MARK: - Draw
extension BottomSheetViewController {
    private func draw() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Grabber
        contentStack.addArrangedSubview(grabberContainer)

        // Title
        if let title = viewModel?.sheetTitle {
            titleLabel.text = title
            contentStack.addArrangedSubview(titleContainer)
        }

        // Subtitle
        if let subtitle = viewModel?.sheetSubtitle {
            subtitleLabel.text = subtitle
            contentStack.addArrangedSubview(subtitleContainer)
            contentStack.setCustomSpacing(12, after: subtitleContainer)
        } else if viewModel?.sheetTitle != nil {
            contentStack.setCustomSpacing(12, after: titleContainer)
        }

        // Custom View
        if let customView = viewModel?.customView {
            let wrapper = UIView()
            wrapper.addSubview(customView)
            customView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(8)
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview().offset(-16)
                $0.bottom.equalToSuperview()
            }
            contentStack.addArrangedSubview(wrapper)
        }

        // Actions
        for action in viewModel?.actions ?? [] {
            let actionView = BottomSheetActionView()
            actionView.configure(with: action)
            actionView.onTap = { [weak self] in
                self?.actionViewTapped(action)
            }
            contentStack.addArrangedSubview(actionView)
            actionViews.append(actionView)
        }

        // Button
        if let buttonModel = viewModel?.button {
            actionButton.setTitle(buttonModel.title, for: .normal)
            actionButton.style = buttonModel.style
            contentStack.addArrangedSubview(buttonContainer)
        }
    }
}

// MARK: - BottomSheetActionView
final class BottomSheetActionView: UIView, PaletteUpdatable {

    // MARK: - Constants
    private let iconSize: CGFloat = 40

    // MARK: - UI
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = ColorBackground.backgroundBorder.color.cgColor
        return view
    }()

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        view.layer.cornerRadius = iconSize / 2
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = Palette.palette1.color
        return view
    }()

    private lazy var iconEmojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 15, fontWeight: .semibold, textColor: ColorText.textPrimary.color)
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.numberOfLines = 1
        return label
    }()

    private lazy var chevronView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = ColorText.textSecondary.color
        view.image = Symbols.chevron_right.symbolSmall()
        return view
    }()

    // MARK: - Closure
    var onTap: EmptyClosure?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        draw()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Gesture
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        onTap?()
    }

    // MARK: - Configure
    func configure(with action: BottomSheetAction) {
        titleLabel.text = action.title
        subtitleLabel.text = action.subtitle
        subtitleLabel.isHidden = action.subtitle == nil

        iconEmojiLabel.text = action.emoji
        iconEmojiLabel.isHidden = action.emoji == nil
        iconImageView.isHidden = action.emoji != nil

        switch action.style {
        case .normal:
            iconContainerView.isHidden = action.icon == nil && action.emoji == nil
            if let icon = action.icon {
                let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
                iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
            }
            chevronView.isHidden = true

        case .selectable:
            if let icon = action.icon {
                iconContainerView.isHidden = false
                let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
                iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
            } else {
                iconContainerView.isHidden = true
                titleLabel.snp.updateConstraints {
                    $0.leading.equalTo(iconContainerView.snp.trailing).offset(-iconSize + 2)
                }
            }

            if action.isSelected {
                chevronView.image = UIImage(systemName: Symbols.checkmark.symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
                chevronView.tintColor = Palette.palette1.color
                chevronView.isHidden = false
            } else {
                chevronView.isHidden = true
            }
        }

        containerView.alpha = action.isEnabled ? 1.0 : 0.4
        isUserInteractionEnabled = action.isEnabled
    }

    // MARK: - PaletteUpdatable
    @objc dynamic func updatePaletteColors() {
        iconImageView.tintColor = Palette.palette1.color
    }
}

// MARK: - BottomSheetActionView Draw
extension BottomSheetActionView {
    private func draw() {
        addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        iconContainerView.addSubview(iconEmojiLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(chevronView)

        // Container
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // Icon container
        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(iconSize)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        iconEmojiLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Chevron
        chevronView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(chevronView.snp.leading).offset(-8)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(titleLabel)
            $0.trailing.lessThanOrEqualTo(chevronView.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().offset(-14)
        }
    }
}
