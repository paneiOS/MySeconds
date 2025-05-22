//
//  VideoRecordInteractor.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol VideoRecordRouting: ViewableRouting {}

protocol VideoRecordPresentable: Presentable {
    var listener: VideoRecordPresentableListener? { get set }
}

public protocol VideoRecordListener: AnyObject {}

final class VideoRecordInteractor: PresentableInteractor<VideoRecordPresentable>, VideoRecordInteractable, VideoRecordPresentableListener {

    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?

    init(presenter: VideoRecordPresentable, component: VideoRecordComponent) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
