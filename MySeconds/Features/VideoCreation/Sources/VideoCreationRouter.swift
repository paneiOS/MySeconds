//
//  VideoCreationRouter.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import UIKit

import ModernRIBs

import BGMSelect
import CoverClipCreation
import SharedModels

protocol VideoCreationInteractable: Interactable, BGMSelectListener, CoverClipCreationListener {
    var router: VideoCreationRouting? { get set }
    var listener: VideoCreationListener? { get set }
    func apply(bgm: BGM)
//    func applyVideoCoverClip(clip: VideoCoverClip)
}

protocol VideoCreationViewControllable: ViewControllable {}

final class VideoCreationRouter: ViewableRouter<VideoCreationInteractable, VideoCreationViewController> {
    private let component: VideoCreationComponent
    private var bgmSelectRouter: BGMSelectRouting?
    private var coverClipCreationRouter: CoverClipCreationRouting?

    init(
        interactor: VideoCreationInteractable,
        viewController: VideoCreationViewController,
        component: VideoCreationComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}

extension VideoCreationRouter: VideoCreationRouting {
    func apply(bgm: BGM) {
        self.interactor.apply(bgm: bgm)
    }

    func applyVideoCoverClip(clip: VideoCoverClip) {
//        self.interactor.applyVideoCoverClip(clip: clip)
    }

    // MARK: - BGMSelect(브금선택)

    func routeToBGMSelect(bgmDirectoryURL: URL) {
        guard bgmSelectRouter == nil else { return }
        let bgmSelectRouter = self.component.bgmSelectBuilder.build(withListener: self.interactor, bgmDirectoryURL: bgmDirectoryURL)
        let bgmSelectViewController = bgmSelectRouter.uiviewController
        bgmSelectViewController.modalPresentationStyle = .overFullScreen
        self.bgmSelectRouter = bgmSelectRouter
        self.attachChild(bgmSelectRouter)
        self.viewController.present(child: bgmSelectRouter.viewControllable, animated: false)
    }

    func closeBGMSelect() {
        guard let bgmSelectRouter else { return }
        self.detachChild(bgmSelectRouter)
        self.viewController.dismiss(animated: true)
        self.bgmSelectRouter = nil
    }

    // MARK: - VideoCoverclip(커버클립제작)

    func routeToCoverClipCreation(clip: VideoCoverClip) {
        guard coverClipCreationRouter == nil else { return }
        let coverClipCreationRouter = self.component.coverClipCreationBuilder.build(withListener: self.interactor, videoCoverClip: clip)
        let coverClipCreationViewController = coverClipCreationRouter.uiviewController
        coverClipCreationViewController.modalPresentationStyle = .overFullScreen
        self.coverClipCreationRouter = coverClipCreationRouter
        self.attachChild(coverClipCreationRouter)
        self.viewController.present(child: coverClipCreationRouter.viewControllable, animated: false)
    }

    func closeCoverClipCreation() {
        guard let coverClipCreationRouter else { return }
        self.detachChild(coverClipCreationRouter)
        self.viewController.dismiss(animated: true)
        self.coverClipCreationRouter = nil
    }
}
