//
//  CoverClipCreationRouter.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import ModernRIBs

import BaseRIBsKit

protocol CoverClipCreationInteractable: Interactable {
    var router: CoverClipCreationRouting? { get set }
    var listener: CoverClipCreationListener? { get set }
}

protocol CoverClipCreationViewControllable: ViewControllable {}

final class CoverClipCreationRouter: BaseRouter<CoverClipCreationInteractor, CoverClipCreationViewController>, CoverClipCreationRouting {

    override init(interactor: CoverClipCreationInteractor, viewController: CoverClipCreationViewController) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
