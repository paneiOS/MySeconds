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

    var timerButtonTextPublisher: PassthroughSubject<String, Never> { get }
    var ratioButtonTextPublisher: PassthroughSubject<String, Never> { get }
    var isRecordingPublisher: PassthroughSubject<Bool, Never> { get }
    var recordDurationPublisher: PassthroughSubject<TimeInterval, Never> { get }
    var albumPublisher: PassthroughSubject<(UIImage?, Int), Never> { get }

    func handleFlip()
    func handleAlbumTap()
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

    private let videoRatios: [String] = ["1:1", "4:3"]
    private var currentRatioIndex: Int = 0

    private var maxRecordingTime: TimeInterval = 1
    private let durationOptions: [TimeInterval] = [1, 2, 3]

    private var cancellables = Set<AnyCancellable>()

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

        self.thumbnailSubject
            .combineLatest(self.albumCountSubject)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] thumbnail, count in
                guard let self else { return }
                self.presenter.albumPublisher.send((thumbnail, count))
            })
            .store(in: &self.cancellables)
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
        let thumb = self.component.initialAlbumThumbnail
        let cnt = self.component.initialAlbumCount

        self.thumbnailSubject.send(thumb)
        self.albumCountSubject.send(cnt)

        let maxRecordingTime = "\(Int(self.maxRecordingTime))초"
        self.presenter.timerButtonTextPublisher.send(maxRecordingTime)
        self.presenter.ratioButtonTextPublisher.send(self.videoRatios[self.currentRatioIndex])
    }
}

extension VideoRecordInteractor {
    func didTapRecord() {
        self.presenter.recordDurationPublisher.send(self.maxRecordingTime)
        self.presenter.isRecordingPublisher.send(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + self.maxRecordingTime) { [weak self] in
            guard let self else { return }

            self.recordDidFinish()
            self.presenter.isRecordingPublisher.send(false)
        }
    }

    func didTapFlip() {
        
    }

    func didTapRatio() {
        let nextIndex = (currentRatioIndex + 1) % self.videoRatios.count
        self.currentRatioIndex = nextIndex
        let newRatioText = self.videoRatios[nextIndex]
        self.presenter.ratioButtonTextPublisher.send(newRatioText)
    }

    func didTapTimer() {
        if let idx = durationOptions.firstIndex(of: maxRecordingTime) {
            self.maxRecordingTime = self.durationOptions[(idx + 1) % self.durationOptions.count]
        } else {
            self.maxRecordingTime = self.durationOptions.first ?? self.maxRecordingTime
        }
        
        let maxRecordingTime = "\(Int(self.maxRecordingTime))초"

        self.presenter.timerButtonTextPublisher.send(maxRecordingTime)
    }

    func didTapAlbum() {
        self.presenter.handleAlbumTap()
    }

    // TODO: 샘플앱을 위한 테스트 메서든 추후 수정 필요
    func recordDidFinish() {
        let currentCount = self.albumCountSubject.value
        let newCount = currentCount + 1
        self.albumCountSubject.send(newCount)

        let colorIndex = newCount % self.sampleColors.count
        let chosenColor = self.sampleColors[colorIndex]
        let thumbnailSize = CGSize(width: 64, height: 64)

        let colorImage = UIGraphicsImageRenderer(size: thumbnailSize).image { ctx in
            chosenColor.setFill()
            ctx.fill(CGRect(origin: .zero, size: thumbnailSize))
        }
        self.thumbnailSubject.send(colorImage)
    }
}
