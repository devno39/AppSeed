//
//  PaywallViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

final class PaywallViewController: BaseViewController<PaywallViewModel, PaywallRouter> {

    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 24
        return stack
    }()

    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = Logo.logo_1024.image
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 26, fontWeight: .bold, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = PaywallLocalizable.title
        return label
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 15, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = PaywallLocalizable.subtitle
        return label
    }()

    private lazy var featureStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private lazy var planStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var monthlyCard: PaywallPlanCard = {
        let card = PaywallPlanCard()
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(monthlyTapped)))
        return card
    }()

    private lazy var yearlyCard: PaywallPlanCard = {
        let card = PaywallPlanCard()
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(yearlyTapped)))
        return card
    }()

    private lazy var ctaButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.setTitle(PaywallLocalizable.cta_continue, for: .normal)
        button.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        return button
    }()

    private lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(PaywallLocalizable.restore, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.tintColor = ColorText.textSecondary.color
        button.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        return button
    }()

    private lazy var termsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(PaywallLocalizable.terms, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.tintColor = ColorText.textSecondary.color
        button.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        return button
    }()

    private lazy var privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(PaywallLocalizable.privacy, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.tintColor = ColorText.textSecondary.color
        button.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        return button
    }()

    private lazy var footerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [restoreButton, termsButton, privacyButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = ColorText.textSecondary.color.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties
    private var selectedPlan: UserPlan = .yearly

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        navigationController?.setNavigationBarHidden(true, animated: false)
        draw()
        configureFeatures()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
        configurePlans()
        selectPlan(.yearly)

        viewModel?.onPricesLoaded = { [weak self] in
            self?.configurePlans()
        }
    }

    // MARK: - Features
    private func configureFeatures() {
        let features: [(String, String, String)] = [
            ("sparkles", PaywallLocalizable.feature_1_title, PaywallLocalizable.feature_1_subtitle),
            ("bolt.fill", PaywallLocalizable.feature_2_title, PaywallLocalizable.feature_2_subtitle),
            ("infinity", PaywallLocalizable.feature_3_title, PaywallLocalizable.feature_3_subtitle)
        ]
        for (icon, title, subtitle) in features {
            featureStack.addArrangedSubview(PaywallFeatureRow(icon: icon, title: title, subtitle: subtitle))
        }
    }

    // MARK: - Plans
    private func configurePlans() {
        monthlyCard.configure(
            title: PaywallLocalizable.plan_monthly,
            price: viewModel?.monthlyPrice.isEmpty == false ? viewModel!.monthlyPrice : "—",
            period: PaywallLocalizable.plan_per_month,
            badge: nil
        )
        yearlyCard.configure(
            title: PaywallLocalizable.plan_yearly,
            price: viewModel?.yearlyPrice.isEmpty == false ? viewModel!.yearlyPrice : "—",
            period: PaywallLocalizable.plan_per_year,
            badge: viewModel?.yearlyDiscountBadge ?? PaywallLocalizable.plan_popular
        )
    }

    private func selectPlan(_ plan: UserPlan) {
        selectedPlan = plan
        monthlyCard.setSelected(plan == .monthly)
        yearlyCard.setSelected(plan == .yearly)
    }

    // MARK: - Actions
    @objc private func monthlyTapped() { selectPlan(.monthly) }
    @objc private func yearlyTapped() { selectPlan(.yearly) }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func ctaTapped() {
        ctaButton.showLoading()
        viewModel?.purchase(plan: selectedPlan) { [weak self] success in
            self?.ctaButton.hideLoading()
            if success { self?.showPurchaseSuccess() }
        }
    }

    @objc private func restoreTapped() {
        ctaButton.showLoading()
        viewModel?.restore { [weak self] success in
            self?.ctaButton.hideLoading()
            if success { self?.showPurchaseSuccess() }
        }
    }

    private func showPurchaseSuccess() {
        dismiss(animated: true) {
            ToastHelper.show(
                icon: "checkmark.seal.fill",
                title: PaywallLocalizable.success_title,
                subtitle: PaywallLocalizable.success_subtitle
            )
        }
    }

    @objc private func termsTapped() {
        viewModel?.openTerms()
    }

    @objc private func privacyTapped() {
        viewModel?.openPrivacy()
    }
}

// MARK: - Draw
extension PaywallViewController {
    private func draw() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(closeButton)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(56)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-24)
            $0.width.equalToSuperview().offset(-48)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(32)
        }

        logoImageView.snp.makeConstraints {
            $0.height.equalTo(88)
        }

        planStack.addArrangedSubview(monthlyCard)
        planStack.addArrangedSubview(yearlyCard)
        planStack.snp.makeConstraints {
            $0.height.equalTo(112)
        }

        ctaButton.snp.makeConstraints {
            $0.height.equalTo(52)
        }

        contentStack.addArrangedSubview(logoImageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(8, after: titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(featureStack)
        contentStack.addArrangedSubview(planStack)
        contentStack.addArrangedSubview(ctaButton)
        contentStack.setCustomSpacing(12, after: ctaButton)
        contentStack.addArrangedSubview(footerStack)
    }
}
