//
//  ItemsViewController.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import UIKit
import SnapKit

final class ItemsViewController: BaseViewController<ItemsViewModel, ItemsRouter> {

    // MARK: - UI
    private lazy var tableView: BaseTableView = {
        let view = BaseTableView(frame: .zero, style: .plain)
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: fabBottomInset, right: 0)
        view.delegate = self
        view.dataSource = self
        view.register(ItemCell.self)
        view.register(EmptyTVCell.self)
        return view
    }()

    private lazy var addButton: FloatingActionButton = {
        let button = FloatingActionButton()
        button.setIcon(name: Symbols.plus.symbolName, color: .white)
        button.onTap = { [weak self] in
            self?.presentAddItem()
        }
        return button
    }()

    // MARK: - Constants
    private let fabBottomInset: CGFloat = 88

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.startListening()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.stopListening()
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()

        viewModel?.itemsDidChange = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Actions
    private func presentAddItem() {
        router?.presentAddItemSheet { [weak self] model in
            self?.viewModel?.addItem(title: model.title, note: model.note, emoji: model.emoji)
        }
    }

    // MARK: - Localization
    override func configureLocalization() {
        title = ItemsLocalizable.title
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        return viewModel.isEmpty ? 1 : viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel else { return UITableViewCell() }

        if viewModel.isEmpty {
            let cell: EmptyTVCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(
                symbol: Symbols.plus,
                title: ItemsLocalizable.empty_title,
                subtitle: ItemsLocalizable.empty_subtitle,
                buttonTitle: ItemsLocalizable.empty_button
            )
            cell.actionClosure = { [weak self] in
                self?.presentAddItem()
            }
            return cell
        }

        let cell: ItemCell = tableView.dequeueReusableCell(for: indexPath)
        if let item = viewModel.item(at: indexPath.row) {
            cell.configure(with: item)
        }
        cell.onToggle = { [weak self] in
            self?.viewModel?.toggleDone(at: indexPath.row)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ItemsViewController: UITableViewDelegate {
    // EmptyTVCell centres its stack with no intrinsic height, so the empty row is sized by
    // hand. Clamped: the first layout pass runs with zero bounds and would go negative.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard viewModel?.isEmpty == true else { return UITableView.automaticDimension }
        let available = tableView.bounds.height - tableView.contentInset.top - fabBottomInset
        return max(available, 0)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard viewModel?.isEmpty == false else { return nil }

        let delete = UIContextualAction(style: .destructive, title: ItemsLocalizable.delete) { [weak self] _, _, done in
            self?.viewModel?.deleteItem(at: indexPath.row)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - Draw
extension ItemsViewController {
    private func draw() {
        view.addSubview(tableView)
        view.addSubview(addButton)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
}
