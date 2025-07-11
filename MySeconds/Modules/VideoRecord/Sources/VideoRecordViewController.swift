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
    func didTapThumbnailButton()
    func didTapAlbumButton()
    func didTapMenuButton()
}

public protocol CustomHeaderNavigation {}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, CustomHeaderNavigation {
    private let headerView: UIView = .init()

    private let logoView: UIImageView = {
        let imageView: UIImageView = .init(image: ResourceKitAsset.mysecondsLogo.image
            .resized(to: .init(width: 96, height: 32))
            .withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .neutral400
        return imageView
    }()

    private let albumButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(
            ResourceKitAsset.image.image
                .resized(to: .init(width: 24, height: 24))
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .neutral400
        return button
    }()

    private let menuButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(
            ResourceKitAsset.menu.image
                .resized(to: .init(width: 24, height: 24))
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .neutral400
        return button
    }()

    private let recordingControlView: RecordingControlView = .init()
    private var cameraPreview = CameraPreviewView()
    private let permissionView = CameraPermissionView()

    weak var listener: VideoRecordPresentableListener?

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden = true
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
    ////        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }

    override func setupUI() {
        self.view.backgroundColor = .white

        self.view.addSubviews(self.headerView, self.recordingControlView, self.cameraPreview, self.permissionView)
        self.headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        self.headerView.addSubviews(self.logoView, self.albumButton, self.menuButton)
        self.logoView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
        }
        self.menuButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        self.albumButton.snp.makeConstraints {
            $0.trailing.equalTo(self.menuButton.snp.leading)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }

        self.permissionView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.recordingControlView.snp.makeConstraints {
            $0.height.equalTo(136)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.cameraPreview.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
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
                self.listener?.didTapThumbnailButton()
            })
            .store(in: &cancellables)

        self.recordingControlView.recordTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapRecord()
            })
            .store(in: &cancellables)

        self.albumButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapAlbumButton()
            })
            .store(in: &self.cancellables)

        self.menuButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.didTapMenuButton()
            })
            .store(in: &self.cancellables)
    }
}
