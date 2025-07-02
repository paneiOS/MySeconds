//
//  RootRouter.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import UIKit

import ModernRIBs

import BGMSelect
import CoverClipCreation
import Login
import SharedModels
import SignUp
import UtilsKit
import VideoCreation
import VideoRecord

protocol RootInteractable: Interactable,
    LoginListener,
    VideoRecordListener,
    VideoCreationListener,
    SignUpListener,
    CoverClipCreationListener,
    BGMSelectListener {
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
    private var videoRecordRouter: VideoRecordRouting?
    private var coverClipCreationRouter: CoverClipCreationRouting?
    private var bgmSelectRouter: BGMSelectRouting?

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

    func routeToVideoRecord(clips: [CompositionClip]) {
        self.popToSignUp()
        self.popToLogin()

        guard self.videoRecordRouter == nil else { return }
        let videoRecordRouter = self.component.videoRecordBuilder.build(withListener: self.interactor, clips: clips)
        self.attachChild(videoRecordRouter)
        self.videoRecordRouter = videoRecordRouter
        self.rootNavigationController?.pushViewController(videoRecordRouter.uiviewController, animated: true)
    }

    func routeToVideoCreation(clips: [CompositionClip]) {
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

    func routeToBGMSelect(bgmDirectoryURL: URL) {
        guard bgmSelectRouter == nil else { return }
        let bgmSelectRouter = self.component.bgmSelectBuilder.build(withListener: self.interactor, bgmDirectoryURL: bgmDirectoryURL)
        let bgmSelectViewController = bgmSelectRouter.uiviewController
        bgmSelectViewController.modalPresentationStyle = .overFullScreen
        self.attachChild(bgmSelectRouter)
        self.bgmSelectRouter = bgmSelectRouter
        self.viewController.present(child: bgmSelectRouter.viewControllable, animated: false)
    }

    func apply(bgm: BGM) {
        self.closeBGMSelect()
        guard let videoCreationRouter else { return }
        videoCreationRouter.apply(bgm: bgm)
    }

    func closeBGMSelect() {
        guard let bgmSelectRouter else { return }
        self.detachChild(bgmSelectRouter)
        self.viewController.dismiss(animated: true)
        self.bgmSelectRouter = nil
    }
}

extension UINavigationController: @retroactive ViewControllable, RootViewControllable {}
