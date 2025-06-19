//
//  VideoCreationRouter.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import BGMSelect
import CoverClipCreation
import SharedModels

protocol VideoCreationInteractable: Interactable {
    var router: VideoCreationRouting? { get set }
    var listener: VideoCreationListener? { get set }
    func apply(bgm: BGM)
}

protocol VideoCreationViewControllable: ViewControllable {}

final class VideoCreationRouter: ViewableRouter<VideoCreationInteractable, VideoCreationViewController> {
    private let component: VideoCreationComponent

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
}
