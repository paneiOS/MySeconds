//
//  VideoRecordViewController.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import AVFoundation
import Combine
import UIKit

import BaseRIBsKit
import SnapKit

import MySecondsKit
import ResourceKit
import SharedModels
import VideoDraftStorage
import VideoRecordingManager

protocol VideoRecordPresentableListener: AnyObject {
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    var recordDurationPublisher: AnyPublisher<TimeInterval, Never> { get }
    var cameraAuthorizationPublisher: AnyPublisher<Bool, Never> { get }
    var aspectRatioPublisher: AnyPublisher<AspectRatio, Never> { get }
    var clipsPublisher: AnyPublisher<[CompositionClip], Never> { get }
    var captureSession: AVCaptureSession { get }

    func initAlbum()
    func startSession()
    func stopSession()
    func didTapRecord()
    func didTapFlip()
    func didTapRatio()
    func didTapTimer()
    func didTapAlbum()
}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, NavigationConfigurable {

    weak var listener: VideoRecordPresentableListener?

    private let recordControlView: RecordControlView
    private var cameraPreview = CameraPreviewView()
    private let permissionView = CameraPermissionView()
    private var currentAspectRatio: AspectRatio = .oneToOne

    init(maxAlbumCount: Int) {
        self.recordControlView = RecordControlView(videoClips: [], maxAlbumCount: maxAlbumCount, recordDuration: 1.0)
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubviews(self.recordControlView, self.cameraPreview, self.permissionView)

        self.permissionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.recordControlView.snp.makeConstraints {
            $0.height.equalTo(136)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.cameraPreview.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.recordControlView.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
    }

    override func bind() {
        self.bindViewEvents()
        self.bindStateBindings()
    }

    private func bindViewEvents() {
        self.viewDidLoadPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.initAlbum()
            })
            .store(in: &cancellables)

        self.recordControlView.recordTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapRecord()

            })
            .store(in: &cancellables)

        self.recordControlView.flipTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapFlip()
            })
            .store(in: &cancellables)

        self.recordControlView.ratioTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapRatio()
            })
            .store(in: &cancellables)

        self.recordControlView.timerTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapTimer()
            })
            .store(in: &cancellables)

        self.recordControlView.albumTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapAlbum()
            })
            .store(in: &cancellables)
    }

    private func bindStateBindings() {
        self.listener?.isRecordingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isRecording in
                guard let self else { return }
                self.recordControlView.setRecordingState(isRecording)
            })
            .store(in: &cancellables)

        self.listener?.recordDurationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] duration in
                guard let self else { return }
                self.recordControlView.recordDuration = duration
                self.recordControlView.setTimerButtonText(seconds: Int(duration))
            })
            .store(in: &cancellables)

        self.listener?.clipsPublisher
            .filter { !$0.isEmpty }
            .compactMap { clips in
                clips.compactMap { clip in
                    if case let .video(videoClip) = clip {
                        videoClip
                    } else {
                        nil
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] videoClips in
                guard let self else { return }
                self.recordControlView.updateAlbum(videos: videoClips)
            })
            .store(in: &self.cancellables)

        self.listener?.cameraAuthorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isAuthorized in
                guard let self else { return }

                self.permissionView.isHidden = isAuthorized

                if isAuthorized {
                    let session = self.listener?.captureSession
                    self.cameraPreview.session = session
                    self.listener?.startSession()
                } else {
                    self.cameraPreview.removeSession()
                    self.listener?.stopSession()
                }
            })
            .store(in: &self.cancellables)

        self.listener?.aspectRatioPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] ratio in
                guard let self else { return }
                self.currentAspectRatio = ratio
                self.cameraPreview.aspectRatio = self.currentAspectRatio.ratio
                self.recordControlView.setRatioButtonText(text: ratio.rawValue)
            })
            .store(in: &self.cancellables)
    }

    func navigationConfig() -> NavigationConfig {
        NavigationConfig(
            leftButtonType: .logo,
            rightButtonTypes: [
                .custom(
                    image: ResourceKitAsset.image.image,
                    tintColor: .neutral400,
                    action: .push(UIViewController())
                ),
                .custom(
                    image: ResourceKitAsset.menu.image,
                    tintColor: .neutral400,
                    action: .push(UIViewController())
                )
            ]
        )
    }
}
