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
import CoverClipCreation
import ExtensionKit
import Login
import ResourceKit
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
    private var loginRouter: LoginRouting?
    private var signUpRouter: SignUpRouting?
    private var videoCreationRouter: VideoCreationRouting?
    private var videoRecordRouter: VideoRecordRouting?
    private var coverClipCreationRouter: CoverClipCreationRouting?
    private var bgmSelectRouter: BGMSelectRouting?
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
        self.navigationController?.delegate = self.navigationDelegateProxy
        interactor.router = self

        self.bindNavigationEvents()
    }

    func routeToLogin() {
        guard self.loginRouter == nil else { return }
        let loginRouter = self.component.loginBuilder.build(withListener: self.interactor)
        self.attachChild(loginRouter)
        self.loginRouter = loginRouter
        self.navigationController?.pushViewController(loginRouter.uiviewController, animated: false)
    }

    func popToLogin() {
        guard let loginRouter else { return }
        self.detachChild(loginRouter)
        self.navigationController?.popViewController(animated: false)
        self.loginRouter = nil
    }

    func routeToVideoRecord(clips: [CompositionClip]) {
        self.popToSignUp()
        self.popToLogin()

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

        let navigationController = UINavigationController(rootViewController: videoRecordRouter.uiviewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.delegate = self.navigationDelegateProxy
        self.navigationController = navigationController

        self.attachChild(videoRecordRouter)
        self.videoRecordRouter = videoRecordRouter
        self.viewController.present(child: navigationController, animated: true)
    }

    func routeToVideoCreation(clips: [CompositionClip]) {
        guard self.videoCreationRouter == nil else { return }
        let videoCreationRouter = self.component.videoCreationBuilder.build(withListener: self.interactor, clips: clips)
        videoCreationRouter.uiviewController.navigationOption = .showsNavigationBar
        self.attachChild(videoCreationRouter)
        self.videoCreationRouter = videoCreationRouter

        let backButton = self.backButton()
        backButton.addTarget(self, action: #selector(self.popToVideoCreation), for: .touchUpInside)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        videoCreationRouter.uiviewController.navigationItem.leftBarButtonItem = backBarButtonItem
        let title: NSAttributedString = .makeAttributedString(
            text: "영상 만들기",
            font: .systemFont(ofSize: 16, weight: .regular),
            textColor: .neutral800,
            alignment: .center
        )
        videoCreationRouter.uiviewController.setAttributedTitle(title)

        self.navigationController?.pushViewController(videoCreationRouter.uiviewController, animated: false)
    }

    @objc func popToVideoCreation() {
        guard let videoCreationRouter else { return }
        self.detachChild(videoCreationRouter)
        self.navigationController?.popViewController(animated: true)
        self.videoCreationRouter = nil
    }

    func routeToSignUp(uid: String) {
        guard self.signUpRouter == nil else { return }
        let signUpRouter = self.component.signUpBuilder.build(withListener: self.interactor, uid: uid)
        self.attachChild(signUpRouter)
        self.signUpRouter = signUpRouter
        self.navigationController?.pushViewController(signUpRouter.uiviewController, animated: true)
    }

    func popToSignUp() {
        guard let signUpRouter else { return }
        self.detachChild(signUpRouter)
        self.navigationController?.popViewController(animated: false)
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

    func applyVideoCoverClip(clip: VideoCoverClip) {
        self.closeCoverClipCreation()
        guard let videoCreationRouter else { return }
        videoCreationRouter.applyVideoCoverClip(clip: clip)
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

    private func bindNavigationEvents() {
        self.navigationDelegateProxy.popedViewControllerPublisher
            .sink(receiveValue: { [weak self] poppedVC in
                guard let self else { return }
                if let videoCreationRouter,
                   poppedVC === videoCreationRouter.uiviewController {
                    self.detachChild(videoCreationRouter)
                    self.videoCreationRouter = nil
                }
            })
            .store(in: &self.cancellables)
    }
}

extension RootRouter {
    private func backButton() -> UIButton {
        let button: UIButton = .init()
        let backImage: UIImage = ResourceKitAsset.chevronLeft.image
            .withRenderingMode(.alwaysTemplate)
            .resized(to: .init(width: 24, height: 24))
            .withTintColor(.neutral800)
        button.setImage(backImage, for: .normal)
        return button
    }
}

extension UINavigationController: @retroactive ViewControllable, RootViewControllable {}

private extension UIViewController {
    func setAttributedTitle(_ attributedTitle: NSAttributedString) {
        let label = UILabel()
        label.attributedText = attributedTitle
        label.sizeToFit()
        self.navigationItem.titleView = label
    }
}
