//
//  UITableView+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 15.09.2023.
//

import UIKit

extension UITableView {
    // MARK: - Cell
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellReuseIdentifier: T.identifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T
        else {
            fatalError("Could not dequeue cell with identifier: \(T.identifier)")
        }
        return cell
    }

    func dequeueReusableCell<T: UITableViewCell>() -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier) as? T
        else {
            fatalError("Could not dequeue cell with identifier: \(T.identifier)")
        }
        return cell
    }

    // MARK: - Header
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: ReusableView {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
    }

    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: ReusableView {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
            fatalError("Could not dequeue header/footer with identifier: \(T.identifier)")
        }
        return view
    }

    // MARK: - Reload
    func reloadSection(_ section: Int, with animation: UITableView.RowAnimation = .none) {
        guard section < numberOfSections else { return }
        reloadSections(IndexSet(integer: section), with: animation)
    }

    // MARK: - Layout
    var visibleContentHeight: CGFloat {
        bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
    }

    var centeredEmptyCellHeight: CGFloat {
        bounds.height - 2 * adjustedContentInset.top
    }
}
