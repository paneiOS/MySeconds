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
import VideoDraftStorage
import VideoRecordingManager

public protocol VideoRecordRouting: ViewableRouting {}

protocol VideoRecordPresentable: Presentable {
    var listener: VideoRecordPresentableListener? { get set }
}

public protocol VideoRecordListener: AnyObject {}

final class VideoRecordInteractor: PresentableInteractor<VideoRecordPresentable>, VideoRecordInteractable, VideoRecordPresentableListener {
    
    private let videoDraftStorage = try? VideoDraftStorage()
    
    private let component: VideoRecordComponent
    private let recordingManager: VideoRecordingManagerProtocol
    
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
    
    private let videosSubject = PassthroughSubject<[VideoDraft], Never>()
    public var videosPublisher: AnyPublisher<[VideoDraft], Never> {
        self.videosSubject.eraseToAnyPublisher()
    }
    
    private let cameraAuthorizationSubject = PassthroughSubject<Bool, Never>()
    var cameraAuthorizationPublisher: AnyPublisher<Bool, Never> {
        self.cameraAuthorizationSubject.eraseToAnyPublisher()
    }
    
    private var currentDurationIndex = 0
    private let durationOptions: [Int] = [1, 2, 3]
    
    private let videoSubject = CurrentValueSubject<[VideoDraft], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    
    weak var router: VideoRecordRouting?
    weak var listener: VideoRecordListener?
    
    init(presenter: VideoRecordPresentable, component: VideoRecordComponent, recordingManager: VideoRecordingManagerProtocol) {
        self.component = component
        self.recordingManager = recordingManager
        super.init(presenter: presenter)
        presenter.listener = self
        
        self.bind()
        self.bindRecordingManager()
    }
    
    private func bind() {
        self.videoSubject
            .sink(receiveValue: { [weak self] videos in
                guard let self else { return }
                self.videosSubject.send(videos)
            })
            .store(in: &self.cancellables)
        
        self.recordingManager
            .requestAuthorizationPublisher()
            .sink(receiveValue: { [weak self] isAuthorized in
                guard let self else { return }
                self.cameraAuthorizationSubject.send(isAuthorized)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindRecordingManager() {
        self.recordingManager.isRecordingPublisher
            .sink(receiveValue: { [weak self] isRecording in
                guard let self else { return }
                self.isRecordingSubject.send(isRecording)
                
                let selectedDuration = self.durationOptions[self.currentDurationIndex]
                let duration = isRecording ? TimeInterval(selectedDuration) : 0
                self.recordDurationSubject.send(duration)
            })
            .store(in: &self.cancellables)
        
        self.recordingManager.aspectRatioTextPublisher
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.ratioButtonTextSubject.send(text)
            })
            .store(in: &self.cancellables)
        
        self.recordingManager.recordedURLPublisher
            .sink(receiveValue: { [weak self] url in
                guard let self else { return }
                Task {
                    await self.saveVideo(url: url)
                }
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
            
            self.videoSubject.send(drafts)
            print("저장 성공 \(filePath?.lastPathComponent ?? "")")
        } catch {
            print("저장 실패", error)
        }
    }
}

extension VideoRecordInteractor {
    func initAlbum() {
        do {
            if let videos = try self.videoDraftStorage?.loadAll(type: VideoDraft.self) {
                _ = videos.sorted {
                    $0.createdAt > $1.createdAt
                }
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
    func didTapRecord() {
        let duration = TimeInterval(durationOptions[currentDurationIndex])
        self.recordingManager.toggleRecording(duration: duration)
    }
    
    func didTapFlip() {
        self.recordingManager.switchCamera()
    }
    
    func didTapRatio() {
        self.recordingManager.changeAspectRatio()
    }
    
    func didTapTimer() {
        self.currentDurationIndex = (self.currentDurationIndex + 1) % self.durationOptions.count
        let selected = self.durationOptions[self.currentDurationIndex]
        self.timerButtonTextSubject.send(selected)
    }
    
    func didTapAlbum() {
        // 앨범 화면 이동
    }
}
