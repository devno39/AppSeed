//
//  LoginViewController.swift
//  AppSeed
//
//  Created by Claude on 19.01.2025.
//

import UIKit
import SnapKit
import AuthenticationServices

final class LoginViewController: BaseViewController<LoginViewModel, LoginRouter> {

    // MARK: - UI
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Logo.logo_1024.image
        imageView.layer.cornerRadius = 28
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorText.textPrimary.color
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorText.textSecondary.color
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 12
        button.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        return button
    }()

    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(agreementTapped(_:)))
        label.addGestureRecognizer(tap)

        return label
    }()

    // MARK: - Constants
    private let logoSize: CGFloat = 120

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        navigationController?.setNavigationBarHidden(true, animated: false)
        draw()
    }

    // MARK: - Localization
    override func configureLocalization() {
        titleLabel.text = LoginLocalizable.title
        subtitleLabel.text = LoginLocalizable.subtitle

        let text = LoginLocalizable.agreement
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: ColorText.textSecondary.color
            ]
        )
        let termsRange = (text as NSString).range(of: LoginLocalizable.agreement_terms)
        let privacyRange = (text as NSString).range(of: LoginLocalizable.agreement_privacy)
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorText.textPrimary.color,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        attributed.addAttributes(linkAttributes, range: termsRange)
        attributed.addAttributes(linkAttributes, range: privacyRange)
        agreementLabel.attributedText = attributed
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
        viewModel?.loginSuccessClosure = { [weak self] userId in
            log(.success, .supabase, "Login Success - User ID: \(userId)")
            UserSessionManager.shared.startListening()
            self?.router?.showTabBar()
        }
    }

    // MARK: - Actions
    @objc private func appleSignInTapped() {
        viewModel?.appleSignIn(self)
    }

    @objc private func agreementTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let attributed = label.attributedText else { return }
        let text = attributed.string

        let termsRange = (text as NSString).range(of: LoginLocalizable.agreement_terms)
        let privacyRange = (text as NSString).range(of: LoginLocalizable.agreement_privacy)

        let tapLocation = gesture.location(in: label)
        let textStorage = NSTextStorage(attributedString: attributed)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let index = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if NSLocationInRange(index, termsRange) {
            open(Configuration.termsURL)
        } else if NSLocationInRange(index, privacyRange) {
            open(Configuration.privacyURL)
        }
    }

    // MARK: - Private
    private func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Draw
extension LoginViewController {

    private func draw() {
        view.addSubview(agreementLabel)
        agreementLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.left.equalToSuperview().offset(32)
            $0.right.equalToSuperview().offset(-32)
        }

        view.addSubview(appleSignInButton)
        appleSignInButton.snp.makeConstraints {
            $0.bottom.equalTo(agreementLabel.snp.top).offset(-16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(56)
        }

        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(-64)
            $0.width.height.equalTo(logoSize)
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }

        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
    }
}
