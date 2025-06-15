//
//  RootRouter.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import UIKit

import ModernRIBs

import CoverClipCreation
import Login
import SharedModels
import SignUp
import UtilsKit
import VideoCreation

protocol RootInteractable: Interactable, LoginListener, VideoCreationListener, SignUpListener, CoverClipCreationListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let component: RootComponent
    private var rootNavigationController: UINavigationController?
    private var loginRouter: LoginRouting?
    private var signUpRouter: SignUpRouting?
    private var videoCreationRouter: VideoCreationRouting?
    private var coverClipCreationRouter: CoverClipCreationRouting?

    init(
        interactor: RootInteractable,
        viewController: RootViewControllable,
        component: RootComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        self.rootNavigationController = viewController.uiviewController as? UINavigationController
        interactor.router = self
    }

    func routeToLogin() {
        guard self.loginRouter == nil else { return }
        let loginRouter = self.component.loginBuilder.build(withListener: self.interactor)
        self.attachChild(loginRouter)
        self.loginRouter = loginRouter
        self.rootNavigationController?.isNavigationBarHidden = true
        self.rootNavigationController?.pushViewController(loginRouter.uiviewController, animated: false)
    }

    func popToLogin() {
        guard let loginRouter else { return }
        self.detachChild(loginRouter)
        self.rootNavigationController?.popViewController(animated: false)
        self.loginRouter = nil
    }

    func routeToVideoCreation(clips: [CompositionClip]) {
        self.popToSignUp()
        self.popToLogin()

        guard self.videoCreationRouter == nil else { return }
        let videoCreationRouter = self.component.videoCreationBuilder.build(withListener: self.interactor, clips: clips)
        self.attachChild(videoCreationRouter)
        self.videoCreationRouter = videoCreationRouter
        self.rootNavigationController?.pushViewController(videoCreationRouter.uiviewController, animated: true)
    }

    func routeToSignUp(uid: String) {
        guard self.signUpRouter == nil else { return }
        let signUpRouter = self.component.signUpBuilder.build(withListener: self.interactor, uid: uid)
        self.attachChild(signUpRouter)
        self.signUpRouter = signUpRouter
        self.rootNavigationController?.pushViewController(signUpRouter.uiviewController, animated: true)
    }

    func popToSignUp() {
        guard let signUpRouter else { return }
        self.detachChild(signUpRouter)
        self.rootNavigationController?.popViewController(animated: false)
        self.signUpRouter = nil
    }

    func routeToCoverClipCreation(clip: VideoCoverClip) {
        guard coverClipCreationRouter == nil else { return }
        let coverClipCreationRouter = self.component.coverClipCreationBuilder.build(withListener: self.interactor, videoCoverClip: clip)
        let coverClipCreationViewController = coverClipCreationRouter.uiviewController
        coverClipCreationViewController.modalPresentationStyle = .overFullScreen
        self.attachChild(coverClipCreationRouter)
        self.coverClipCreationRouter = coverClipCreationRouter
        self.viewController.present(child: coverClipCreationRouter.viewControllable, animated: false)
    }

    func closeCoverClipCreation() {
        guard let coverClipCreationRouter else { return }
        self.detachChild(coverClipCreationRouter)
        self.viewController.dismiss(animated: true)
        self.coverClipCreationRouter = nil
    }
}

extension UINavigationController: @retroactive ViewControllable, RootViewControllable {}
