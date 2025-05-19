//
//  SignUpRouter.swift
//  MySeconds
//
//  Created by pane on 04/23/2025.
//

import ModernRIBs

import BaseRIBsKit

protocol SignUpInteractable: Interactable {
    var router: SignUpRouting? { get set }
    var listener: SignUpListener? { get set }
}

protocol SignUpViewControllable: ViewControllable {}

final class SignUpRouter: BaseRouter<SignUpInteractor, SignUpViewController>, SignUpRouting {

    override init(interactor: SignUpInteractor, viewController: SignUpViewController) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
