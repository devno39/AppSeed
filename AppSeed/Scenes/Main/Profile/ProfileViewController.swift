//
//  ProfileViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

final class ProfileViewController: BaseViewController<ProfileViewModel, ProfileRouter> {
    // MARK: - UI
    private lazy var tableView: BaseTableView = {
        let view = BaseTableView(frame: .zero, style: .grouped)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        return view
    }()

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
        registerCells()
    }

    private func registerCells() {
        tableView.sectionHeaderTopPadding = 0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView()
        tableView.register(ProfileHeaderCell.self)
        tableView.register(ProfileActionCell.self)
        tableView.registerHeaderFooterView(BaseSectionHeaderView.self)
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()

        viewModel?.dataDidChange = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel?.logoutSuccessClosure = { [weak self] in
            self?.router?.showLogin()
        }

        viewModel?.deleteAccountSuccessClosure = { [weak self] in
            self?.router?.showLogin()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleUserDidChange), name: .userDidChange, object: nil)

        viewModel?.fetchUser()
    }

    // MARK: - Localization
    override func configureLocalization() {
        title = ProfileLocalizable.title
        tableView.reloadData()
    }

    // MARK: - Session Observers
    @objc private func handleUserDidChange() {
        viewModel?.fetchUser()
    }

    // MARK: - Actions
    private func showLanguageSheet() {
        let current = LanguageManager.shared.currentLanguage
        let actions: [BottomSheetAction] = AppLanguage.allCases.map { language in
            BottomSheetAction(
                title: language.displayTitle,
                style: .selectable,
                isSelected: current == language,
                handler: { LanguageManager.shared.setLanguage(language) }
            )
        }
        router?.presentBottomSheet(title: ProfileLocalizable.item_language, actions: actions)
    }

    private func showThemeSheet() {
        let current = ThemeManager.shared.currentTheme
        let actions: [BottomSheetAction] = [
            BottomSheetAction(
                title: ProfileLocalizable.theme_system,
                style: .selectable,
                isSelected: current == .system,
                handler: { ThemeManager.shared.setTheme(.system) }
            ),
            BottomSheetAction(
                title: ProfileLocalizable.theme_light,
                style: .selectable,
                isSelected: current == .light,
                handler: { ThemeManager.shared.setTheme(.light) }
            ),
            BottomSheetAction(
                title: ProfileLocalizable.theme_dark,
                style: .selectable,
                isSelected: current == .dark,
                handler: { ThemeManager.shared.setTheme(.dark) }
            )
        ]
        router?.presentBottomSheet(title: ProfileLocalizable.item_theme, actions: actions)
    }

    private func deleteAccountTapped() {
        AlertHelper.showAlert(
            title: ProfileLocalizable.delete_account_alert_title,
            message: ProfileLocalizable.delete_account_alert_message,
            primaryTitle: ProfileLocalizable.alert_cancel,
            secondaryTitle: ProfileLocalizable.delete_account_alert_confirm,
            secondaryStyle: .destructive,
            secondaryAction: { [weak self] in
                self?.viewModel?.deleteAccount()
            }
        )
    }

    private func logoutTapped() {
        AlertHelper.showAlert(
            title: ProfileLocalizable.logout_alert_title,
            message: ProfileLocalizable.logout_alert_message,
            primaryTitle: ProfileLocalizable.alert_cancel,
            secondaryTitle: ProfileLocalizable.logout_alert_confirm,
            secondaryStyle: .destructive,
            secondaryAction: { [weak self] in
                self?.viewModel?.logout()
            }
        )
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.numberOfSections() ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfItems(in: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel?.item(at: indexPath) else { return UITableViewCell() }

        switch item {
        case .header:
            let cell: ProfileHeaderCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: viewModel?.headerModel ?? ProfileHeaderModel(userName: nil, email: nil, avatarURL: nil))
            cell.editUserClosure = { [weak self] in
                self?.viewModel?.editProfileClosure?()
            }
            return cell
        default:
            let cell: ProfileActionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: item)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = viewModel?.section(at: section)?.title else { return nil }
        let header: BaseSectionHeaderView = tableView.dequeueHeaderFooterView()
        header.configure(title: title)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = viewModel?.section(at: section)?.title, !title.isEmpty else {
            return .leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = viewModel?.item(at: indexPath) else { return }
        switch item {
        case .language:
            showLanguageSheet()
        case .theme:
            showThemeSheet()
        case .logout:
            logoutTapped()
        case .deleteAccount:
            deleteAccountTapped()
        default:
            break
        }
    }
}

// MARK: - Draw
extension ProfileViewController {
    private func draw() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
