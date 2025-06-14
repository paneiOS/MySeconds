//
//  RootRouter.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import UIKit

import ModernRIBs

import Login
import SharedModels
import SignUp
import UtilsKit
import VideoCreation

protocol RootInteractable: Interactable, LoginListener, VideoCreationListener, SignUpListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let component: RootComponent
    private var loginRouter: LoginRouting?
    private var signUpRouter: SignUpRouting?
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
        let loginRouter = self.component.loginBuilder.build(withListener: self.interactor)
        loginRouter.viewControllable.uiviewController.modalPresentationStyle = .fullScreen
        self.attachChild(loginRouter)
        self.loginRouter = loginRouter
        self.viewController.present(child: loginRouter.viewControllable, animated: false)
    }

    func dismissLogin() {
        guard let loginRouter else { return }
        self.detachChild(loginRouter)
        self.viewController.dismiss()
        self.loginRouter = nil
    }

    func routeToVideoCreation(clips: [CompositionClip]) {
        if let signUp = signUpRouter {
            detachChild(signUp)
            signUp.viewControllable.dismiss()
            self.signUpRouter = nil
        }

        if let login = loginRouter {
            detachChild(login)
            viewController.dismiss()
            self.loginRouter = nil
        }

        guard self.videoCreationRouter == nil else { return }
        let videoCreationRouter = self.component.videoCreationBuilder.build(withListener: self.interactor, clips: clips)
        videoCreationRouter.viewControllable.uiviewController.modalPresentationStyle = .fullScreen
        self.attachChild(videoCreationRouter)
        self.videoCreationRouter = videoCreationRouter
        self.viewController.present(child: videoCreationRouter.viewControllable, animated: true)
    }

    func routeToSignUp(uid: String) {
        guard let loginRouter, self.signUpRouter == nil else { return }
        let signUpRouter = self.component.signUpBuilder.build(withListener: self.interactor, uid: uid)
        signUpRouter.viewControllable.uiviewController.modalPresentationStyle = .fullScreen
        self.attachChild(signUpRouter)
        self.signUpRouter = signUpRouter
        let loginViewControllable = loginRouter.viewControllable
        loginViewControllable.present(child: signUpRouter.viewControllable, animated: true)
    }
}
