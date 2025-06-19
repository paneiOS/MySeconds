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

import AVFoundation
import VideoDraftStorage

public protocol VideoRecordRouting: ViewableRouting {}

protocol VideoRecordPresentable: Presentable {
    var listener: VideoRecordPresentableListener? { get set }
}

public protocol VideoRecordListener: AnyObject {}

final class VideoRecordInteractor: PresentableInteractor<VideoRecordPresentable>, VideoRecordInteractable, VideoRecordPresentableListener {

    private let videoDraftStorage = try? VideoDraftStorage()

    private let component: VideoRecordComponent
    private let cameraManager: CameraManagerProtocol

    private let timerButtonTextSubject = PassthroughSubject<Int, Never>()
    public var timerButtonTextPublisher: AnyPublisher<Int, Never> {
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

    private let authorizationSubject = CurrentValueSubject<Bool, Never>(false)
    public var authorizationPublisher: AnyPublisher<Bool, Never> {
        self.authorizationSubject.eraseToAnyPublisher()
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
                Task {
                    await self.saveVideo(url: url)
                }
            })
            .store(in: &self.cancellables)

        self.cameraManager.authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isAuthorized in
                guard let self else { return }
                self.authorizationSubject.send(isAuthorized)
            })
            .store(in: &self.cancellables)
    }

    private func saveVideo(url: URL) async {
        guard let thumbnail = url.generateThumbnail(),
              let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) else {
            print("썸네일 생성 실패")
            return
        }

        do {
            let duration = try await url.videoDuration()

            let draft = VideoDraft(
                duration: duration,
                thumbnail: thumbnailData
            )

            let filePath = try self.videoDraftStorage?.saveVideoDraft(sourceURL: url, fileName: draft.fileBaseName)
            var drafts = try self.videoDraftStorage?.loadAll(type: VideoDraft.self) ?? []
            drafts.append(draft)
            try self.videoDraftStorage?.updateBackup(drafts)

            self.thumbnailSubject.send(thumbnail)
            self.albumCountSubject.send(drafts.count)
            print("저장 성공 \(filePath?.lastPathComponent ?? "")")
        } catch {
            print("저장 실패", error)
        }
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
        do {
            let videos = try self.videoDraftStorage?.loadAll(type: VideoDraft.self)
            let sorted = videos?.sorted {
                $0.createdAt > $1.createdAt
            }
            let thumbnail = sorted?.first.flatMap {
                UIImage(data: $0.thumbnail)
            }
            let count = videos?.count ?? 0

            self.thumbnailSubject.send(thumbnail)
            self.albumCountSubject.send(count)
        } catch {
            self.thumbnailSubject.send(nil)
            self.albumCountSubject.send(0)
        }
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
