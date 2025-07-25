//
//  CoverClipCreationRouter.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import UIKit

import ModernRIBs

import SharedModels

protocol CoverClipCreationInteractable: Interactable {
    var router: CoverClipCreationRouting? { get set }
    var listener: CoverClipCreationListener? { get set }
}

protocol CoverClipCreationViewControllable: ViewControllable {}

final class CoverClipCreationRouter: ViewableRouter<CoverClipCreationInteractable, CoverClipCreationViewController> {

    override init(
        interactor: CoverClipCreationInteractable,
        viewController: CoverClipCreationViewController
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}

extension CoverClipCreationRouter: CoverClipCreationRouting {}
