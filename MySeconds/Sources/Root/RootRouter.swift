//
//  RootRouter.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import Login
import SharedModels
import UtilsKit
import VideoCreation

protocol RootInteractable: Interactable, LoginListener, VideoCreationListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let component: RootComponent
    private var loginRouter: LoginRouting?
    private var videoCreationRouter: VideoCreationRouting?

    init(
        interactor: RootInteractable,
        viewController: RootViewControllable,
        component: RootComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToLogin() {
        guard self.loginRouter == nil else { return }
        let router = self.component.loginBuilder.build(withListener: self.interactor)
        self.attachChild(router)
        self.loginRouter = router
        self.viewController.uiviewController.modalPresentationStyle = .fullScreen
        self.viewController.present(child: router.viewControllable, animated: true)
    }

    func dismissLogin() {
        guard let router = loginRouter else { return }
        detachChild(router)
        viewController.dismiss()
        self.loginRouter = nil
    }

    func routeToVideoCreation(clips: [CompositionClip]) {
        guard self.videoCreationRouter == nil else { return }
        let router = self.component.videoCreationBuilder.build(withListener: self.interactor, clips: clips)
        self.attachChild(router)
        self.videoCreationRouter = router
        self.viewController.uiviewController.modalPresentationStyle = .fullScreen
        self.viewController.present(child: router.viewControllable, animated: true)
    }
}
