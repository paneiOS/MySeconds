//
//  VideoCreationRouter.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import BaseRIBsKit

protocol VideoCreationInteractable: Interactable {
    var router: VideoCreationRouting? { get set }
    var listener: VideoCreationListener? { get set }
}

protocol VideoCreationViewControllable: ViewControllable {}

final class VideoCreationRouter: BaseRouter<VideoCreationInteractor, VideoCreationViewController>, VideoCreationRouting {

    override init(interactor: VideoCreationInteractor, viewController: VideoCreationViewController) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
