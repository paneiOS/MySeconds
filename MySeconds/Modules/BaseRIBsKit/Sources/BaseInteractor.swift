//
//  BaseInteractor.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import Combine

import ModernRIBs

public protocol BaseRouting: ViewableRouting {}

public protocol BaseListener: AnyObject {}

open class BaseInteractor<PresenterType>: PresentableInteractor<PresenterType> {
    public weak var router: BaseRouting?
    public weak var listener: BaseListener?

    public var cancellables = Set<AnyCancellable>()

    override public init(presenter: PresenterType) {
        super.init(presenter: presenter)
        print("🧠 Init: \(type(of: self))")
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}

extension BaseInteractor: BaseresentableListener {}
