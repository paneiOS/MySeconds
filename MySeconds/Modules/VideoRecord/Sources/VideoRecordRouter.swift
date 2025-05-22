//
//  VideoRecordRouter.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import ModernRIBs

import BaseRIBsKit

protocol VideoRecordInteractable: Interactable {
    var router: VideoRecordRouting? { get set }
    var listener: VideoRecordListener? { get set }
}

protocol VideoRecordViewControllable: ViewControllable {}

final class VideoRecordRouter: BaseRouter<VideoRecordInteractor, VideoRecordViewController>, VideoRecordRouting {

    override init(interactor: VideoRecordInteractor, viewController: VideoRecordViewController) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
