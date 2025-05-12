//
//  BaseViewController.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import Combine
import UIKit

import ModernRIBs

protocol BaseresentableListener: AnyObject {}

public protocol BaseViewControllable: ViewControllable {}

open class BaseViewController: UIViewController, BaseViewControllable {

    // MARK: - Combine

    public var cancellables = Set<AnyCancellable>()

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    public var viewDidLoadPublisher: AnyPublisher<Void, Never> {
        self.viewDidLoadSubject.eraseToAnyPublisher()
    }

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

        self.viewDidLoadSubject.send(())
    }

    // MARK: - Overridable Hooks

    open func setupUI() {
        self.view.backgroundColor = .white
    }

    open func bind() {}
}
