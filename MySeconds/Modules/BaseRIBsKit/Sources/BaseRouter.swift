//
//  BaseRouter.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import ModernRIBs

open class BaseRouter<InteractorType: Interactable, ViewControllerType: ViewControllable>: ViewableRouter<InteractorType, ViewControllerType> {

    override public init(interactor: InteractorType, viewController: ViewControllerType) {
        super.init(interactor: interactor, viewController: viewController)
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}
