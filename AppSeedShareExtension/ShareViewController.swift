//
//  ShareViewController.swift
//  AppSeedShareExtension
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import UniformTypeIdentifiers

// The extension target links no third-party packages — plain anchors, no SnapKit.
final class ShareViewController: UIViewController {

    // MARK: - UI
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 44)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Constants
    private let dismissDelay: TimeInterval = 1.6

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        draw()
        handleInput()
    }

    // MARK: - Input
    private func handleInput() {
        let providers = (extensionContext?.inputItems as? [NSExtensionItem])?
            .flatMap { $0.attachments ?? [] } ?? []

        if let urlProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, _ in
                let url = (item as? URL)
                    ?? (item as? Data).flatMap { URL(dataRepresentation: $0, relativeTo: nil) }
                self?.finish(with: PendingSharedItem(url: url?.absoluteString, text: nil))
            }
            return
        }

        if let textProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
            textProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] item, _ in
                self?.finish(with: PendingSharedItem(url: nil, text: item as? String))
            }
            return
        }

        finish(with: nil)
    }

    private func finish(with item: PendingSharedItem?) {
        let isValid = item?.url != nil || item?.text != nil
        if let item, isValid {
            PendingSharedItem.save(item)
        }
        DispatchQueue.main.async { [weak self] in
            self?.showResult(success: isValid)
        }
    }

    // MARK: - Result
    private func showResult(success: Bool) {
        emojiLabel.text = success ? "📥" : "🤔"
        titleLabel.text = success ? ShareLocalizable.savedTitle : ShareLocalizable.notFoundTitle
        subtitleLabel.text = success ? ShareLocalizable.savedSubtitle : nil
        subtitleLabel.isHidden = !success

        UIView.animate(withDuration: 0.25) {
            self.cardView.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        }
    }
}

// MARK: - Draw
extension ShareViewController {
    private func draw() {
        view.addSubview(cardView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 260),

            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            emojiLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
    }
}
