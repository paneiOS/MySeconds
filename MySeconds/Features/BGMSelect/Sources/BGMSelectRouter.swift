//
//  BGMSelectRouter.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import ModernRIBs

import BaseRIBsKit

protocol BGMSelectInteractable: Interactable {
    var router: BGMSelectRouting? { get set }
    var listener: BGMSelectListener? { get set }
}

protocol BGMSelectViewControllable: ViewControllable {}

final class BGMSelectRouter: ViewableRouter<BGMSelectInteractor, BGMSelectViewController>, BGMSelectRouting {

    override init(interactor: BGMSelectInteractor, viewController: BGMSelectViewController) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}
