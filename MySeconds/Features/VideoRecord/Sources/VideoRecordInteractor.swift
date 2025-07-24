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

public protocol VideoRecordRouting: ViewableRouting {
    func routeToVideoCreation(clips: [CompositionClip])
    func showAlbumRIB()
    func showMenuRIB()
    func routeToCoverClipCreation(clip: VideoCoverClip)
    func routeToBGMSelect(bgmDirectoryURL: URL)
    func popToVideoCreation()
//    func applyVideoCoverClip(clip: VideoCoverClip)
//    func routeToVideoCreation(clips: [CompositionClip])
//    func popToVideoCreation()
}

protocol VideoRecordPresentable: Presentable {
    var listener: VideoRecordPresentableListener? { get set }
}

public protocol VideoRecordListener: AnyObject {}

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
            let uuid: UUID = .init()
            let date: Date = .init()
            let videoClip = VideoClip(
                id: uuid,
                createdAt: date,
                fileName: date.formattedString(format: "yyyyMMdd_HHmmssSSS") + "_" + uuid.uuidString,
                duration: recordDuration,
                thumbnail: thumbnail
            )
            let currentClips = self.clipsSubject.value
            let videoLastIndex = currentClips.count - self.coverClipsCount / 2
            let updatedClips = try self.videoDraftStorage.saveVideoClip(
                videoClip,
                at: videoLastIndex,
                into: currentClips,
                sourceURL: url
            )
            self.clipsSubject.send(updatedClips)
            print("✅ 저장 개수: \(updatedClips.count)")
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
                self.isRecordingSubject.send(false)
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

    func didTapThumbnailButton() {
        guard self.clipsSubject.value.count - self.coverClipsCount > 0 else { return }
        self.router?.routeToVideoCreation(clips: self.clipsSubject.value)
    }

    func didTapAlbumButton() {
        self.router?.showAlbumRIB()
    }

    func didTapMenuButton() {
        self.router?.showMenuRIB()
    }

    // MARK: - VideoCreation

    func didSelectCoverClip(clip: VideoCoverClip) {
        self.router?.routeToCoverClipCreation(clip: clip)
    }

    func popToVideoCreation() {
        self.router?.popToVideoCreation()
    }

    func didUpdateClips(_ clips: [CompositionClip]) {
        self.clipsSubject.send(clips)
    }

    func applyVideoCoverClip(clip: SharedModels.VideoCoverClip) {}

    func closeCoverClipCreation() {}
}
