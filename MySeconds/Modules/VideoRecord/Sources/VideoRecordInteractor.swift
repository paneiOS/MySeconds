//
//  VideoRecordInteractor.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import Combine
import UIKit

import ModernRIBs

import BaseRIBsKit

public protocol VideoRecordRouting: ViewableRouting {}

protocol VideoRecordPresentable: Presentable {
    var listener: VideoRecordPresentableListener? { get set }
}

public protocol VideoRecordListener: AnyObject {}

final class VideoRecordInteractor: PresentableInteractor<VideoRecordPresentable>, VideoRecordInteractable, VideoRecordPresentableListener {

    private let component: VideoRecordComponent

    private let thumbnailSubject = CurrentValueSubject<UIImage?, Never>(nil)
    private let albumCountSubject = CurrentValueSubject<Int, Never>(0)

    public var thumbnailPublisher: AnyPublisher<UIImage?, Never> {
        self.thumbnailSubject.eraseToAnyPublisher()
    }

    public var albumCountPublisher: AnyPublisher<Int, Never> {
        self.albumCountSubject.eraseToAnyPublisher()
    }

    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?

    init(presenter: VideoRecordPresentable, component: VideoRecordComponent) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
        let thumb = self.component.initialAlbumThumbnail
        let cnt = self.component.initialAlbumCount

        self.thumbnailSubject.send(thumb)
        self.albumCountSubject.send(cnt)
    }
}
