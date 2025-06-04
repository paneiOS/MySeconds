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

    // TODO: 테스트를 위한 프로퍼티
    private let sampleColors: [UIColor] = [
        .black,
        .red,
        .blue,
        .green,
        .yellow,
        .purple
    ]

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

extension VideoRecordInteractor {

    func recordDidFinish() {
        let currentCount = self.albumCountSubject.value
        let newCount = currentCount + 1
        self.albumCountSubject.send(newCount)

        let colorIndex = newCount % self.sampleColors.count
        let chosenColor = self.sampleColors[colorIndex]

        let thumbnailSize = CGSize(width: 64, height: 64)
        let colorImage = self.makeImage(with: chosenColor, size: thumbnailSize)

        self.thumbnailSubject.send(colorImage)
    }

    private func makeImage(with color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
