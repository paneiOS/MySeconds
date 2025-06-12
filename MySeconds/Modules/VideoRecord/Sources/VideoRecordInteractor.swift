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

    private let timerButtonTextSubject = PassthroughSubject<String, Never>()
    public var timerButtonTextPublisher: AnyPublisher<String, Never> {
        self.timerButtonTextSubject.eraseToAnyPublisher()
    }

    private let ratioButtonTextSubject = PassthroughSubject<String, Never>()
    public var ratioButtonTextPublisher: AnyPublisher<String, Never> {
        self.ratioButtonTextSubject.eraseToAnyPublisher()
    }

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    public var isRecordingPublisher: AnyPublisher<Bool, Never> {
        self.isRecordingSubject.eraseToAnyPublisher()
    }

    private let recordDurationSubject = PassthroughSubject<TimeInterval, Never>()
    public var recordDurationPublisher: AnyPublisher<TimeInterval, Never> {
        self.recordDurationSubject.eraseToAnyPublisher()
    }

    private let albumSubject = PassthroughSubject<(UIImage?, Int), Never>()
    public var albumPublisher: AnyPublisher<(UIImage?, Int), Never> {
        self.albumSubject.eraseToAnyPublisher()
    }

    private let thumbnailSubject = CurrentValueSubject<UIImage?, Never>(nil)
    private let albumCountSubject = CurrentValueSubject<Int, Never>(0)

    private let videoRatios: [String] = ["1:1", "4:3"]
    private var currentRatioIndex: Int = 0
    private var maxRecordingTime: TimeInterval = 1
    private let durationOptions: [TimeInterval] = [1, 2, 3]
    private var recordWorkItem: DispatchWorkItem?

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

        self.bind()
    }

    private func bind() {
        self.thumbnailSubject
            .combineLatest(self.albumCountSubject)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] thumbnail, count in
                guard let self else { return }
                self.albumSubject.send((thumbnail, count))
            })
            .store(in: &self.cancellables)
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
        self.thumbnailSubject.send(self.component.initialAlbumThumbnail)
        self.albumCountSubject.send(self.component.initialAlbumCount)

        let maxRecordingTime = "\(Int(self.maxRecordingTime))초"
        self.timerButtonTextSubject.send(maxRecordingTime)
        self.ratioButtonTextSubject.send(self.videoRatios[self.currentRatioIndex])
    }
}

extension VideoRecordInteractor {
    func didTapRecord() {
        if self.isRecordingSubject.value {
            self.recordWorkItem?.cancel()
            self.isRecordingSubject.send(false)
            self.recordDurationSubject.send(0)
        } else {
            self.recordDurationSubject.send(self.maxRecordingTime)
            self.isRecordingSubject.send(true)

            let work = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.recordDidFinish()
                self.isRecordingSubject.send(false)
            }
            self.recordWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + self.maxRecordingTime, execute: work)
        }
    }

    func didTapFlip() {
        print("Tap Flip")
    }

    func didTapRatio() {
        let nextIndex = (currentRatioIndex + 1) % self.videoRatios.count

        self.videoRatios[safe: nextIndex].map { [weak self] newRatio in
            guard let self else { return }
            self.currentRatioIndex = nextIndex
            self.ratioButtonTextSubject.send(newRatio)
        }
    }

    func didTapTimer() {
        let nextIndex = self.durationOptions
            .firstIndex(of: self.maxRecordingTime)
            .map { ($0 + 1) % self.durationOptions.count }
            ?? 0

        self.durationOptions[safe: nextIndex].map { [weak self] next in
            guard let self else { return }
            self.maxRecordingTime = next
            self.timerButtonTextSubject.send("\(Int(next))초")
        }
    }

    func didTapAlbum() {
        print("Tap Album")
    }

    // TODO: 샘플앱을 위한 테스트 메서든 추후 수정 필요
    func recordDidFinish() {

        let newCount = self.albumCountSubject.value + 1
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
