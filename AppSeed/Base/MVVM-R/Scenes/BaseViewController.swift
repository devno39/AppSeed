//
//  BaseViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class BaseViewController<V: BaseViewModelProtocol, R: BaseRouterProtocol>: UIViewController {

    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()

    // MARK: - Properties
    var isScrollable: Bool { false }

    // Sheets override to false — they manage their own keyboard handling.
    var adjustsScrollForKeyboard: Bool { true }

    var keyboardAdjustableScrollView: UIScrollView? { nil }

    var keyboardDismissExcludedViews: [UIView] { [] }

    private(set) var isKeyboardVisible = false

    // MARK: - Dependency
    var viewModel: V?
    var router: R?

    // MARK: - Init
    required init(viewModel: V, router: R) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router?.viewController = self
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        log(.info, .lifecycle, "🔴 deinit: \(self.description)")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        observeChanges()
    }

    // MARK: - Prepare
    func prepare() {
        log(.info, .lifecycle, "🟢 didLoad: \(self.description)")
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        draw()
        configureLocalization()
        configurePalette()
        setupKeyboard()
    }

    // MARK: - Bind
    func bindViewModel() {
        // handle viewModel closures here
    }

    // MARK: - Override Points
    func configureLocalization() {}
    func configurePalette() {}
    func keyboardWillShow(keyboardHeight: CGFloat) {}
    func keyboardWillHide() {}

    // MARK: - Toast
    func showToast(icon: String? = nil, title: String, subtitle: String? = nil, autoDismiss: Bool = true, duration: TimeInterval = 3.0) {
        ToastHelper.show(in: view, icon: icon, title: title, subtitle: subtitle, autoDismiss: autoDismiss, duration: duration)
    }

    func showToastOverNavBar(icon: String? = nil, title: String, subtitle: String? = nil, autoDismiss: Bool = true, duration: TimeInterval = 3.0) {
        guard let navView = navigationController?.view else {
            showToast(icon: icon, title: title, subtitle: subtitle, autoDismiss: autoDismiss, duration: duration)
            return
        }
        ToastHelper.show(in: navView, icon: icon, title: title, subtitle: subtitle, autoDismiss: autoDismiss, duration: duration)
    }

    // MARK: - Keyboard
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(baseKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(baseKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        let tap = UITapGestureRecognizer(target: self, action: #selector(baseDismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func baseDismissKeyboard(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        if let hitView = view.hitTest(point, with: nil), hitView is UIControl {
            return
        }
        for excluded in keyboardDismissExcludedViews {
            let frame = excluded.convert(excluded.bounds, to: view)
            if frame.contains(point) { return }
        }
        view.endEditing(true)
    }

    @objc private func baseKeyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
        guard adjustsScrollForKeyboard,
              let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = frame.height

        if let scrollView = keyboardAdjustableScrollView {
            let bottomInset = keyboardHeight - view.safeAreaInsets.bottom
            scrollView.contentInset.bottom = bottomInset
            scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        }

        keyboardWillShow(keyboardHeight: keyboardHeight)
    }

    @objc private func baseKeyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
        guard adjustsScrollForKeyboard else { return }
        if let scrollView = keyboardAdjustableScrollView {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }

        keyboardWillHide()
    }

    // MARK: - Observers
    private func observeChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: .languageDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePaletteChange),
            name: .paletteDidChange,
            object: nil
        )
    }

    @objc private func handleLanguageChange() {
        reloadDataSources()
        configureLocalization()
    }

    @objc private func handlePaletteChange() {
        refreshPaletteColors(in: view)
        reloadDataSources()
        configurePalette()
    }

    private func refreshPaletteColors(in parent: UIView) {
        for subview in parent.subviews {
            if let updatable = subview as? PaletteUpdatable {
                updatable.updatePaletteColors()
            }
            if let button = subview as? BaseButton {
                button.applyStyle()
            }
            refreshPaletteColors(in: subview)
        }
    }

    private func reloadDataSources() {
        reloadDataSources(in: view)
    }

    private func reloadDataSources(in parent: UIView) {
        for subview in parent.subviews {
            if let tableView = subview as? UITableView {
                tableView.reloadData()
            } else if let collectionView = subview as? UICollectionView {
                collectionView.reloadData()
            } else {
                reloadDataSources(in: subview)
            }
        }
    }
}

// MARK: - Draw
extension BaseViewController {
    private func draw() {
        if isScrollable {
            view.addSubview(scrollView)
            scrollView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            scrollView.addSubview(stackView)
            stackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalToSuperview()
            }
        }
    }
}

// MARK: - ScrollView
extension BaseViewController {
    func addToScrollView(_ view: UIView) {
        guard isScrollable else { return }
        stackView.addArrangedSubview(view)
    }

    func addToScrollView(_ views: [UIView]) {
        guard isScrollable else { return }
        views.forEach { stackView.addArrangedSubview($0) }
    }

    func setScrollViewInsets(top: CGFloat, bottom: CGFloat) {
        guard isScrollable else { return }
        scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }

    func setScrollViewStackInsets(left: CGFloat, right: CGFloat) {
        guard isScrollable else { return }
        stackView.snp.updateConstraints {
            $0.left.equalToSuperview().offset(left)
            $0.right.equalToSuperview().offset(-right)
            $0.width.equalToSuperview().inset((left + right) / 2)
        }
    }

    func setScrollViewStackSpacing(_ spacing: CGFloat) {
        guard isScrollable else { return }
        stackView.spacing = spacing
    }

    func setSpacingAfter(spacing: CGFloat, after view: UIView) {
        guard isScrollable else { return }
        stackView.setCustomSpacing(spacing, after: view)
    }
}
