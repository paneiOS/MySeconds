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
    var captureSession: AVCaptureSession { get }
    var cameraAuthorizationPublisher: AnyPublisher<Bool, Never> { get }
    var thumbnailPublisher: AnyPublisher<UIImage?, Never> { get }
    var albumCountPublisher: AnyPublisher<(Int, Int), Never> { get }
    var recordDurationPublisher: AnyPublisher<TimeInterval, Never> { get }
    var ratioTypePublisher: AnyPublisher<RatioType, Never> { get }
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }

    func initVideoRecordRIB()
    func startSession()
    func stopSession()
    func didTapRecord()
    func didTapFlip()
    func didTapRatio()
    func didTapTimer()
    func didTapAlbum()
}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, NavigationConfigurable {
    private let recordingControlView: RecordingControlView = .init()
    private var cameraPreview = CameraPreviewView()
    private let permissionView = CameraPermissionView()
    weak var listener: VideoRecordPresentableListener?

    override func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubviews(self.recordingControlView, self.cameraPreview, self.permissionView)

        self.permissionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.recordingControlView.snp.makeConstraints {
            $0.height.equalTo(136)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.cameraPreview.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.recordingControlView.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
    }

    override func bind() {
        self.viewDidLoadPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.initVideoRecordRIB()
            })
            .store(in: &self.cancellables)

        self.bindState()
        self.bindActions()
    }

    private func bindActions() {
        self.recordingControlView.timerTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapTimer()
            })
            .store(in: &cancellables)

        self.recordingControlView.ratioTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapRatio()
            })
            .store(in: &cancellables)

        self.recordingControlView.flipTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapFlip()
            })
            .store(in: &cancellables)

        self.recordingControlView.albumTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapAlbum()
            })
            .store(in: &cancellables)

        self.recordingControlView.recordTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapRecord()

            })
            .store(in: &cancellables)
    }

    private func bindState() {
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

        // MARK: - recordingControlView

        self.listener?.thumbnailPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                guard let self else { return }
                self.recordingControlView.setThumbnail(image: image)
            })
            .store(in: &self.cancellables)

        self.listener?.albumCountPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] currentCount, maxCount in
                guard let self else { return }
                self.recordingControlView.setAlbumCountText(currentCount: currentCount, maxCount: maxCount)
            })
            .store(in: &self.cancellables)

        self.listener?.recordDurationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] duration in
                guard let self else { return }
                self.recordingControlView.setTimer(time: duration)
            })
            .store(in: &self.cancellables)

        self.listener?.ratioTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] ratioType in
                guard let self else { return }
                self.recordingControlView.setRatioButtonText(text: ratioType.rawValue)
                // TODO: - 여기 비율을 주는 방식을 바꿔야할것같음 체크해야함...
                self.cameraPreview.ratioType = ratioType.ratio
            })
            .store(in: &self.cancellables)

        self.listener?.isRecordingPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isRecording in
                guard let self else { return }
                self.recordingControlView.updateRecordingState(isRecording)
            })
            .store(in: &cancellables)
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
