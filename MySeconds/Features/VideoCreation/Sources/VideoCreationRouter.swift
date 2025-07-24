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

protocol VideoCreationInteractable: Interactable, BGMSelectListener {
    var router: VideoCreationRouting? { get set }
    var listener: VideoCreationListener? { get set }
    func apply(bgm: BGM)
//    func applyVideoCoverClip(clip: VideoCoverClip)
}

protocol VideoCreationViewControllable: ViewControllable {}

final class VideoCreationRouter: ViewableRouter<VideoCreationInteractable, VideoCreationViewController> {
    private let component: VideoCreationComponent
    private var bgmSelectRouter: BGMSelectRouting?

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
}
