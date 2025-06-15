//
//  VideoCreationRouter.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import CoverClipCreation
import SharedModels

protocol VideoCreationInteractable: Interactable {
    var router: VideoCreationRouting? { get set }
    var listener: VideoCreationListener? { get set }
}

protocol VideoCreationViewControllable: ViewControllable {}

final class VideoCreationRouter: ViewableRouter<VideoCreationInteractable, VideoCreationViewController>, VideoCreationRouting {
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
