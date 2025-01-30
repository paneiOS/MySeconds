//
//  RootRouter.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import Login
import UtilsKit

protocol RootInteractable: Interactable, LoginListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let component: RootComponent
    private var loginRouter: LoginRouting?

    init(
        interactor: RootInteractable,
        viewController: RootViewControllable,
        component: RootComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func attachLogin() {
        guard self.loginRouter == nil else { return }
        let loginRouter = self.component.loginBuilder.build(withListener: interactor)
        attachChild(loginRouter)
        self.viewControllable.uiviewController.modalPresentationStyle = .fullScreen
        self.viewControllable.present(viewController: loginRouter.viewControllable, animated: true)
    }

    func detachLogin() {
        guard let router = loginRouter else { return }
        detachChild(router)
        viewController.dismiss(viewController: router.viewControllable)

        self.loginRouter = nil
    }
}
