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

    private let videoDraftStorage = try? VideoDraftStorage()

    private let component: VideoRecordComponent
    private let recordingManager: VideoRecordingManagerProtocol

    private let timerButtonTextSubject = PassthroughSubject<Int, Never>()
    public var timerButtonTextPublisher: AnyPublisher<Int, Never> {
        self.timerButtonTextSubject.eraseToAnyPublisher()
    }

    private let aspectRatioSubject = CurrentValueSubject<AspectRatio, Never>(.oneToOne)
    public var aspectRatioPublisher: AnyPublisher<AspectRatio, Never> {
        self.aspectRatioSubject.eraseToAnyPublisher()
    }

    public var ratioButtonTextPublisher: AnyPublisher<String, Never> {
        self.aspectRatioSubject
            .map(\.rawValue)
            .eraseToAnyPublisher()
    }

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    public var isRecordingPublisher: AnyPublisher<Bool, Never> {
        self.isRecordingSubject.eraseToAnyPublisher()
    }

    private let recordDurationSubject = PassthroughSubject<TimeInterval, Never>()
    public var recordDurationPublisher: AnyPublisher<TimeInterval, Never> {
        self.recordDurationSubject.eraseToAnyPublisher()
    }

//    private let albumSubject = PassthroughSubject<(UIImage?, Int), Never>()
//    public var albumPublisher: AnyPublisher<(UIImage?, Int), Never> {
//        self.albumSubject.eraseToAnyPublisher()
//    }

//    private let thumbnailSubject = CurrentValueSubject<UIImage?, Never>(nil)
//    private let albumCountSubject = CurrentValueSubject<Int, Never>(0)
    private let clipsSubject = CurrentValueSubject<[CompositionClip], Never>([])
    public var clipsPublisher: AnyPublisher<[CompositionClip], Never> {
        self.clipsSubject.eraseToAnyPublisher()
    }

    private let videosSubject = PassthroughSubject<[VideoDraft], Never>()
    public var videosPublisher: AnyPublisher<[VideoDraft], Never> {
        self.videosSubject.eraseToAnyPublisher()
    }

    private let videoRatios: [String] = ["1:1", "4:3"]
    private var currentRatioIndex: Int = 0
    private var maxRecordingTime: TimeInterval = 1
    private let durationOptions: [TimeInterval] = [1, 2, 3]
    private var recordWorkItem: DispatchWorkItem?
    private let cameraAuthorizationSubject = PassthroughSubject<Bool, Never>()
    public var cameraAuthorizationPublisher: AnyPublisher<Bool, Never> {
        self.cameraAuthorizationSubject.eraseToAnyPublisher()
    }

    public var captureSession: AVCaptureSession {
        self.recordingManager.session
    }

    private var currentDurationIndex = 0
    private let durationOptions: [Int] = [1, 2, 3]
    private let availableRatios: [AspectRatio] = [.oneToOne, .fourToThree]
    private var currentAspectRatioIndex: Int = 0

    private let videoSubject = CurrentValueSubject<[VideoDraft], Never>([])

    private var clips: [CompositionClip] = []

    private var cancellables = Set<AnyCancellable>()

    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?

    init(
        presenter: VideoRecordPresentable,
        component: VideoRecordComponent,
        recordingManager: VideoRecordingManagerProtocol
    ) {
        self.component = component
        self.recordingManager = recordingManager
        super.init(presenter: presenter)
        presenter.listener = self

        self.bind()
    }

    private func bind() {
//        self.thumbnailSubject
//            .combineLatest(self.albumCountSubject)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] thumbnail, count in
//                guard let self else { return }
//                self.albumSubject.send((thumbnail, count))
//            })
//            .store(in: &self.cancellables)

        self.videoSubject
            .sink(receiveValue: { [weak self] videos in
                guard let self else { return }
                self.videosSubject.send(videos)
            })
            .store(in: &self.cancellables)

        Task {
            let isAuthorized = await self.recordingManager.requestAuthorization(aspectRatio: .oneToOne)
            self.cameraAuthorizationSubject.send(isAuthorized)
        }
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

            self.videoSubject.send(drafts)
            print("저장 성공 \(filePath?.lastPathComponent ?? "")")
        } catch {
            print("저장 실패", error)
        }
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
//        self.thumbnailSubject.send(self.component.initialAlbumThumbnail)
//        self.albumCountSubject.send(self.component.initialAlbumCount)

        self.clipsSubject.send(self.component.clips)
        self.clips = self.component.clips

        let maxRecordingTime = "\(Int(self.maxRecordingTime))초"
        self.timerButtonTextSubject.send(maxRecordingTime)
        self.ratioButtonTextSubject.send(self.videoRatios[self.currentRatioIndex])


        do {
            if let videos = try self.videoDraftStorage?.loadAll(type: VideoDraft.self).sorted(by: { $0.createdAt > $1.createdAt }) {
                self.videoSubject.send(videos)
            } else {
                self.videoSubject.send([])
            }
        } catch {
            self.videoSubject.send([])
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
        self.currentAspectRatioIndex = (self.currentAspectRatioIndex + 1) % self.availableRatios.count
        let newAspectRatio = self.availableRatios[safe: self.currentAspectRatioIndex] ?? .oneToOne
        self.aspectRatioSubject.send(newAspectRatio)
    }

    func didTapTimer() {
        self.currentDurationIndex = (self.currentDurationIndex + 1) % self.durationOptions.count
        let selected = self.durationOptions[safe: self.currentDurationIndex] ?? 1
        self.timerButtonTextSubject.send(selected)
    }

    func didTapAlbum() {
        self.listener?.showVideoCreation(clips: self.clips)
    }

    // TODO: 샘플앱을 위한 테스트 메서든 추후 수정 필요
//    func recordDidFinish() {
//
//        let newCount = self.albumCountSubject.value + 1
//        self.albumCountSubject.send(newCount)
//
//        let colorIndex = newCount % self.sampleColors.count
//        let chosenColor = self.sampleColors[colorIndex]
//        let thumbnailSize = CGSize(width: 64, height: 64)
//
//        let colorImage = UIGraphicsImageRenderer(size: thumbnailSize).image { ctx in
//            chosenColor.setFill()
//            ctx.fill(CGRect(origin: .zero, size: thumbnailSize))
//        }
//        self.thumbnailSubject.send(colorImage)
//    }
}
