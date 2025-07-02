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
    private let component: VideoRecordComponent
    private let recordingManager: VideoRecordingManagerProtocol
    private let videoDraftStorage: VideoDraftStorageDelegate

    private let aspectRatioSubject = CurrentValueSubject<AspectRatio, Never>(.oneToOne)
    public var aspectRatioPublisher: AnyPublisher<AspectRatio, Never> {
        self.aspectRatioSubject.eraseToAnyPublisher()
    }

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    public var isRecordingPublisher: AnyPublisher<Bool, Never> {
        self.isRecordingSubject.eraseToAnyPublisher()
    }

    private let recordDurationSubject: CurrentValueSubject<TimeInterval, Never>
    public var recordDurationPublisher: AnyPublisher<TimeInterval, Never> {
        self.recordDurationSubject.eraseToAnyPublisher()
    }

    private let clipsSubject = CurrentValueSubject<[CompositionClip], Never>([])
    public var clipsPublisher: AnyPublisher<[CompositionClip], Never> {
        self.clipsSubject.eraseToAnyPublisher()
    }

    private let videoRatios: [AspectRatio] = [.oneToOne, .fourToThree]
    private var currentRatioIndex: Int = 0
    private let durationOptions: [TimeInterval] = [1, 2, 3]
    private var currentDurationIndex = 0
    private var recordWorkItem: DispatchWorkItem?
    private let cameraAuthorizationSubject = PassthroughSubject<Bool, Never>()
    public var cameraAuthorizationPublisher: AnyPublisher<Bool, Never> {
        self.cameraAuthorizationSubject.eraseToAnyPublisher()
    }

    public var captureSession: AVCaptureSession {
        self.recordingManager.session
    }

    private var clips: [CompositionClip] = []

    private var cancellables = Set<AnyCancellable>()

    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?

    init(
        presenter: VideoRecordPresentable,
        component: VideoRecordComponent
    ) {
        self.component = component
        self.recordingManager = component.videoRecordingManager
        self.videoDraftStorage = component.videoDraftStorage

        self.recordDurationSubject = .init(1)

        super.init(presenter: presenter)
        presenter.listener = self
    }

    private func saveVideo(url: URL) async {
        guard let thumbnail = url.generateThumbnail() else {
            print("썸네일 생성 실패")
            return
        }

        do {
            // 1. VideoClip 생성
            let videoClip = VideoClip(
                duration: self.recordDurationSubject.value,
                thumbnail: thumbnail
            )

            // 2. mp4 파일 복사 및 원본 삭제
            try self.videoDraftStorage.saveVideoDraft(
                sourceURL: url,
                fileName: videoClip.fileName
            )

            // 3. 기존 CompositionClip 목록 불러오기
            var drafts = try self.videoDraftStorage.loadAll(type: CompositionClip.self)

            // 4. 새로 생성한 VideoClip → CompositionClip.video()로 감싸서 추가
            drafts.append(.video(videoClip))

            // 5. 전체 백업 업데이트
            try self.videoDraftStorage.updateBackup(drafts)

            // 6. 현재 클립 목록도 갱신
            self.clipsSubject.send(drafts)

            print("✅ 저장 성공: \(videoClip.fileName)")
        } catch {
            print("❌ 저장 실패", error)
        }
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
        Task {
            let isAuthorized = await self.recordingManager.requestAuthorization(aspectRatio: .oneToOne)
            self.cameraAuthorizationSubject.send(isAuthorized)
        }

        self.clipsSubject.send(self.clips)
        do {
            let clips = try self.videoDraftStorage.loadAll(type: CompositionClip.self)
            self.clipsSubject.send(clips)
        } catch {
            self.clipsSubject.send([])
        }
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
        if self.isRecordingSubject.value {
            self.recordingManager.cancelRecording()
            return
        }

        let duration = TimeInterval(durationOptions[safe: currentDurationIndex] ?? 1)

        self.isRecordingSubject.send(true)
        self.recordDurationSubject.send(duration)

        Task {
            do {
                let url = try await self.recordingManager.recordVideo(duration: duration)
                self.isRecordingSubject.send(false)
                await self.saveVideo(url: url)
            } catch {
                self.isRecordingSubject.send(false)
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
        self.currentRatioIndex = (self.currentRatioIndex + 1) % self.videoRatios.count
        let newAspectRatio = self.videoRatios[safe: self.currentRatioIndex] ?? .oneToOne
        self.aspectRatioSubject.send(newAspectRatio)
    }

    func didTapTimer() {
        self.currentDurationIndex = (self.currentDurationIndex + 1) % self.durationOptions.count
        let selected = self.durationOptions[safe: self.currentDurationIndex] ?? 1
        self.recordDurationSubject.send(selected)
    }

    func didTapAlbum() {
        self.listener?.showVideoCreation(clips: self.clipsSubject.value)
    }
}
