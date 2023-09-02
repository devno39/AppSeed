//
//  BaseViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class BaseViewController<V: BaseViewModelProtocol>: UIViewController {
    // MARK: - Dependency
    let viewModel: V
    
    // MARK: - Init
    required init(viewModel: V) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // TODO: - create a custom logger
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepare()
    }
    
    // MARK: - Prapare
    func prepare() {
        // Additional setup code can be placed here
        view.backgroundColor = .backgroundPrimary
    }
}

// MARK: - ViewModel Delegate
extension BaseViewController: BaseViewModelDelegate { }
