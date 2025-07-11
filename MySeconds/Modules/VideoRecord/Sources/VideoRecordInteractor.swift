//
//  VideoRecordInteractor.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import AVFoundation
import Combine
import UIKit

import ModernRIBs

import BaseRIBsKit
import SharedModels
import VideoDraftStorage
import VideoRecordingManager

public protocol VideoRecordRouting: ViewableRouting {}

protocol VideoRecordPresentable: Presentable {
    var listener: VideoRecordPresentableListener? { get set }
}

public protocol VideoRecordListener: AnyObject {
    func showVideoCreation(clips: [CompositionClip])
}

final class VideoRecordInteractor: PresentableInteractor<VideoRecordPresentable>, VideoRecordInteractable, VideoRecordPresentableListener {
    private let cameraAuthorizationSubject = PassthroughSubject<Bool, Never>()
    var cameraAuthorizationPublisher: AnyPublisher<Bool, Never> {
        self.cameraAuthorizationSubject.eraseToAnyPublisher()
    }

    private let thumbnailSubject = PassthroughSubject<UIImage?, Never>()
    var thumbnailPublisher: AnyPublisher<UIImage?, Never> {
        self.thumbnailSubject.eraseToAnyPublisher()
    }

    private let albumCountSubject = PassthroughSubject<(Int, Int), Never>()
    var albumCountPublisher: AnyPublisher<(Int, Int), Never> {
        self.albumCountSubject.eraseToAnyPublisher()
    }

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    var isRecordingPublisher: AnyPublisher<Bool, Never> {
        self.isRecordingSubject.eraseToAnyPublisher()
    }

    private let ratioTypeSubject = PassthroughSubject<RatioType, Never>()
    var ratioTypePublisher: AnyPublisher<RatioType, Never> {
        self.ratioTypeSubject.eraseToAnyPublisher()
    }

    private let recordDurationSubject = PassthroughSubject<TimeInterval, Never>()
    var recordDurationPublisher: AnyPublisher<TimeInterval, Never> {
        self.recordDurationSubject.eraseToAnyPublisher()
    }

    private let clipsSubject = CurrentValueSubject<[CompositionClip], Never>([])

    public var captureSession: AVCaptureSession {
        self.recordingManager.session
    }

    private let recordingManager: VideoRecordingManagerProtocol
    private let videoDraftStorage: VideoDraftStorageDelegate

    private let recordDurations: [TimeInterval]
    private var durationIndex: Int = 0
    private let ratioTypes: [RatioType]
    private var ratioIndex: Int = 0
    private let coverClipsCount: Int
    private let maxVideoClipsCount: Int

    private let videoSubject = CurrentValueSubject<[VideoDraft], Never>([])

    private var cancellables = Set<AnyCancellable>()

    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?

    init(
        presenter: VideoRecordPresentable,
        component: VideoRecordComponent
    ) {
        self.videoDraftStorage = component.videoDraftStorage
        self.recordingManager = component.videoRecordingManager
        self.recordDurations = component.recordingOptions.recordDurations
        self.ratioTypes = component.recordingOptions.ratioTypes
        self.coverClipsCount = component.recordingOptions.coverClipsCount
        self.maxVideoClipsCount = component.recordingOptions.maxVideoClipsCount
        super.init(presenter: presenter)
        presenter.listener = self

        self.bind()
    }

    private func saveVideo(url: URL) async {
        guard let thumbnail = url.generateThumbnail() else {
            print("썸네일 생성 실패")
            return
        }
        guard let recordDuration = self.recordDurations[safe: self.durationIndex] else {
            return
        }
        do {
            let videoClip = VideoClip(
                duration: recordDuration,
                thumbnail: thumbnail
            )
            try self.videoDraftStorage.saveVideoDraft(
                sourceURL: url,
                fileName: videoClip.fileName
            )
            var clips = try self.videoDraftStorage.loadAll(type: CompositionClip.self)
            // outro -1, 인덱스 0부터 시작 -1
            let videoIndex = clips.count - 2
            clips.insert(.video(videoClip), at: videoIndex)
            try self.videoDraftStorage.updateBackup(clips)
            self.clipsSubject.send(clips)
            print("✅ 저장 개수: \(clips.count)")
            print("✅ 저장 성공: \(videoClip.fileName)")
        } catch {
            print("❌ 저장 실패", error)
        }
    }
}

extension VideoRecordInteractor {
    func initVideoRecordRIB() {
        Task {
            let isAuthorized = await self.recordingManager.requestAuthorization(ratioType: .oneToOne)
            self.cameraAuthorizationSubject.send(isAuthorized)
        }

        if let clips = try? self.videoDraftStorage.loadAll(type: CompositionClip.self) {
            self.clipsSubject.send(clips)
        }

        if let duration = self.recordDurations[safe: self.durationIndex] {
            self.recordDurationSubject.send(duration)
        }

        if let ratio = self.ratioTypes[safe: self.ratioIndex] {
            self.ratioTypeSubject.send(ratio)
        }
    }

    func bind() {
        self.clipsSubject
            .sink(receiveValue: { [weak self] clips in
                guard let self else { return }
                let videoClips = clips.compactMap { clip -> VideoClip? in
                    if case let .video(videoClip) = clip {
                        videoClip
                    } else {
                        nil
                    }
                }
                if let lastVideo = videoClips.last {
                    self.thumbnailSubject.send(lastVideo.thumbnail)
                } else {
                    self.thumbnailSubject.send(nil)
                }
                self.albumCountSubject.send((clips.count - self.coverClipsCount, self.maxVideoClipsCount))
            })
            .store(in: &self.cancellables)
    }
}

extension VideoRecordInteractor {
    func startSession() {
        self.recordingManager.startSession()
    }

    func stopSession() {
        self.recordingManager.stopSession()
    }

    func didTapRecord() {
        guard !self.isRecordingSubject.value else {
            self.recordingManager.cancelRecording()
            return
        }
        guard let duration = self.recordDurations[safe: self.durationIndex] else { return }
        self.isRecordingSubject.send(true)
        Task {
            do {
                let url = try await self.recordingManager.recordVideo(duration: duration)
                await self.saveVideo(url: url)
            } catch {
                if let cameraError = error as? CameraError {
                    switch cameraError {
                    case .cancelled:
                        print("사용자 취소")
                    default:
                        print("녹화 실패 \(cameraError)")
                    }
                } else {
                    print("녹화 에러 \(error)")
                }
            }
            // TODO: - 딜레이가 느껴짐, 개선필요
            // 저장로직을 백그라운드로 돌리면 실패시 처리가 부자연스러움
            // 현재처럼 딜레이를 느낄지, 실패할 확률이 적으니 예외처리를 부자연스럽게 가져갈지 선택해야함
            self.isRecordingSubject.send(false)
        }
    }

    func didTapFlip() {
        self.recordingManager.switchCamera()
    }

    func didTapRatio() {
        self.ratioIndex = (self.ratioIndex + 1) % self.ratioTypes.count
        guard let ratio = self.ratioTypes[safe: ratioIndex] else { return }
        self.ratioTypeSubject.send(ratio)
    }

    func didTapTimer() {
        self.durationIndex = (self.durationIndex + 1) % self.recordDurations.count
        guard let time = self.recordDurations[safe: self.durationIndex] else { return }
        self.recordDurationSubject.send(time)
    }

    func didTapAlbum() {
        self.listener?.showVideoCreation(clips: self.clipsSubject.value)
    }
}
