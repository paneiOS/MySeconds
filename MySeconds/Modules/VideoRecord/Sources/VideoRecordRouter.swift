//
//  VideoRecordRouter.swift
//  MySeconds
//
//  Created by chungwussup on 02/18/2025.
//

import ModernRIBs

protocol VideoRecordInteractable: Interactable {
    var router: VideoRecordRouting? { get set }
    var listener: VideoRecordListener? { get set }
}

protocol VideoRecordViewControllable: ViewControllable {}

final class VideoRecordRouter: ViewableRouter<VideoRecordInteractable, VideoRecordViewControllable>, VideoRecordRouting {

    override init(interactor: VideoRecordInteractable, viewController: VideoRecordViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
