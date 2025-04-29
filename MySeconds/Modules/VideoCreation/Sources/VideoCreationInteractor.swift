//
//  VideoCreationInteractor.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol VideoCreationRouting: ViewableRouting {}

protocol VideoCreationPresentable: Presentable {
    var listener: VideoCreationPresentableListener? { get set }
}

public protocol VideoCreationListener: AnyObject {}

final class VideoCreationInteractor: PresentableInteractor<VideoCreationPresentable>, VideoCreationInteractable, VideoCreationPresentableListener {

    weak var router: VideoCreationRouting?
    weak var listener: VideoCreationListener?

    init(presenter: VideoCreationPresentable, component: VideoCreationComponent) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
