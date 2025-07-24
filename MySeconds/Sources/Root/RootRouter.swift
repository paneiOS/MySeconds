//
//  RootRouter.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import Combine
import UIKit

import ModernRIBs

import BGMSelect
import ComponentsKit
import Login
import SharedModels
import SignUp
import UtilsKit
import VideoRecord

protocol RootInteractable: Interactable,
    LoginListener,
    VideoRecordListener,
    SignUpListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let component: RootComponent
    private var loginRouter: LoginRouting?
    private var signUpRouter: SignUpRouting?
    private var videoRecordRouter: VideoRecordRouting?
    private var navigationController: UINavigationController?
    private let navigationDelegateProxy = NavigationDelegateProxy()
    private var cancellables = Set<AnyCancellable>()

    init(
        interactor: RootInteractable,
        viewController: RootViewControllable,
        component: RootComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        self.navigationController = viewController.uiviewController as? UINavigationController
        interactor.router = self
    }

    func routeToLogin() {
        guard self.loginRouter == nil else { return }
        let loginRouter = self.component.loginBuilder.build(withListener: self.interactor)
        self.loginRouter = loginRouter
        self.attachChild(loginRouter)
        self.navigationController?.pushViewController(loginRouter.uiviewController, animated: false)
    }

    func popToLogin() {
        guard let loginRouter else { return }
        self.navigationController?.popViewController(animated: false)
        self.detachChild(loginRouter)
        self.loginRouter = nil
    }

    func routeToSignUp(uid: String) {
        guard self.signUpRouter == nil else { return }
        let signUpRouter = self.component.signUpBuilder.build(withListener: self.interactor, uid: uid)
        self.signUpRouter = signUpRouter
        self.attachChild(signUpRouter)
        self.navigationController?.pushViewController(signUpRouter.uiviewController, animated: true)
    }

    func popToSignUp() {
        guard let signUpRouter else { return }
        self.navigationController?.popViewController(animated: false)
        self.detachChild(signUpRouter)
        self.signUpRouter = nil
    }

    func routeToVideoRecord(clips: [CompositionClip]) {
        guard self.videoRecordRouter == nil else { return }
        let recordingOptions: RecordingOptions = .init(
            coverClipsCount: 2,
            maxVideoClipsCount: 15,
            recordDurations: [1.0, 2.0, 3.0],
            ratioTypes: [.oneToOne, .threeToFour]
        )
        let videoRecordRouter = self.component.videoRecordBuilder.build(
            withListener: self.interactor,
            clips: clips,
            recordingOptions: recordingOptions
        )
        videoRecordRouter.uiviewController.navigationOption = .hidesNavigationBar
        self.videoRecordRouter = videoRecordRouter
        self.attachChild(videoRecordRouter)

        self.navigationController?.delegate = self.navigationDelegateProxy
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self.navigationDelegateProxy

        Task { @MainActor in
            self.navigationController?.setViewControllers([videoRecordRouter.uiviewController], animated: false)
        }

        self.popToSignUp()
        self.popToLogin()
    }

    func applyVideoCoverClip(clip: VideoCoverClip) {
//        self.closeCoverClipCreation()
//        guard let videoCreationRouter else { return }
//        videoCreationRouter.applyVideoCoverClip(clip: clip)
    }

//    func apply(bgm: BGM) {
//        self.closeBGMSelect()
//        guard let videoCreationRouter else { return }
//        videoCreationRouter.apply(bgm: bgm)
//    }
}

extension UINavigationController: @retroactive ViewControllable, RootViewControllable {}
