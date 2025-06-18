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
    private let cameraManager: CameraManagerProtocol

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
    private var cancellables = Set<AnyCancellable>()

    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?

    init(presenter: VideoRecordPresentable, component: VideoRecordComponent, cameraManager: CameraManagerProtocol) {
        self.component = component
        self.cameraManager = cameraManager
        super.init(presenter: presenter)
        presenter.listener = self

        self.bind()
        self.bindCameraManager()
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

    private func bindCameraManager() {
        self.cameraManager.isRecordingPublisher
            .sink(receiveValue: { [weak self] isRecording in
                guard let self else { return }
                self.isRecordingSubject.send(isRecording)
                let duration = self.cameraManager.duration(isRecording: isRecording)
                self.recordDurationSubject.send(TimeInterval(duration))
            })
            .store(in: &self.cancellables)

        self.cameraManager.aspectRatioTextPublisher
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.ratioButtonTextSubject.send(text)
            })
            .store(in: &self.cancellables)

        self.cameraManager.durationTextPublisher
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.timerButtonTextSubject.send(text)
            })
            .store(in: &self.cancellables)

        self.cameraManager.recordedURLPublisher
            .sink(receiveValue: { [weak self] url in
                guard let self else { return }
                print("recordedURLPublisher \(url)")
            })
            .store(in: &self.cancellables)
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
        self.thumbnailSubject.send(self.component.initialAlbumThumbnail)
        self.albumCountSubject.send(self.component.initialAlbumCount)
    }
}

extension VideoRecordInteractor {
    func didTapRecord() {
        self.cameraManager.toggleRecording()
    }

    func didTapFlip() {
        self.cameraManager.switchCamera()
    }

    func didTapRatio() {
        self.cameraManager.changeAspectRatio()
    }

    func didTapTimer() {
        self.cameraManager.changeDuration()
    }

    func didTapAlbum() {
        // 앨범 화면 이동
    }
}
