//
//  VideoRecordInteractor.swift
//  MySeconds
//
//  Created by chungwussup on 02/18/2025.
//

import ModernRIBs

protocol VideoRecordRouting: ViewableRouting {}

protocol VideoRecordPresentable: Presentable {
    var listener: VideoRecordPresentableListener? { get set }
}

protocol VideoRecordListener: AnyObject {}

final class VideoRecordInteractor: PresentableInteractor<VideoRecordPresentable>, VideoRecordInteractable, VideoRecordPresentableListener {

    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?

    override init(presenter: VideoRecordPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
