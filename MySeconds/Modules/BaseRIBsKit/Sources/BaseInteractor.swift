//
//  BaseInteractor.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import Combine

import ModernRIBs

open class BaseInteractor<PresenterType>: PresentableInteractor<PresenterType> {
    public weak var router: Routing?

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
