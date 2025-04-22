//
//  BaseViewController.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import Combine
import UIKit

import ModernRIBs

open class BaseViewController: UIViewController, ViewControllable {

    // MARK: - Combine

    public var cancellables = Set<AnyCancellable>()

    // MARK: - Init / Deinit

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder _: NSCoder) { nil }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }

    // MARK: - Life Cycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.bind()
    }

    // MARK: - Overridable Hooks

    open func setupUI() {
        self.view.backgroundColor = .white
    }

    open func bind() {}
}
