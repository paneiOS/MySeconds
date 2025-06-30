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
import VideoDraftStorage
import VideoRecordingManager

protocol VideoRecordPresentableListener: AnyObject {
    var captureSession: AVCaptureSession { get }
    var timerButtonTextPublisher: AnyPublisher<Int, Never> { get }
    var ratioButtonTextPublisher: AnyPublisher<String, Never> { get }
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    var recordDurationPublisher: AnyPublisher<TimeInterval, Never> { get }
    var videosPublisher: AnyPublisher<[VideoDraft], Never> { get }
    var cameraAuthorizationPublisher: AnyPublisher<Bool, Never> { get }
    var aspectRatioPublisher: AnyPublisher<AspectRatio, Never> { get }

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
    private var cameraPreview: UIView = .init()
    private let permissionView = CameraPermissionView()

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentAspectRatio: AspectRatio = .oneToOne

    override init() {
        self.recordControlView = RecordControlView(videos: [], maxAlbumCount: 15)
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updatePreviewLayout()
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
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(62)
            $0.bottom.equalTo(self.recordControlView.snp.top).offset(-62)
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
        self.listener?.timerButtonTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.recordControlView.setTimerButtonText(seconds: text)
            })
            .store(in: &cancellables)

        self.listener?.ratioButtonTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] seconds in
                guard let self else { return }
                self.recordControlView.setRatioButtonText(text: seconds)
            })
            .store(in: &cancellables)

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
            })
            .store(in: &cancellables)

        self.listener?.videosPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] videos in
                guard let self else { return }
                self.recordControlView.updateAlbum(videos: videos)
            })
            .store(in: &cancellables)

        self.listener?.cameraAuthorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isAuthorized in
                guard let self else { return }

                self.permissionView.isHidden = isAuthorized

                if isAuthorized, self.previewLayer == nil, let listener = self.listener {
                    let session = listener.captureSession
                    let layer = AVCaptureVideoPreviewLayer(session: session)
                    layer.videoGravity = .resizeAspectFill
                    self.cameraPreview.layer.insertSublayer(layer, at: 0)
                    self.previewLayer = layer
                    self.updatePreviewLayout()
                    self.listener?.startSession()
                } else {
                    self.previewLayer?.removeFromSuperlayer()
                    self.previewLayer = nil
                    self.listener?.stopSession()
                }
            })
            .store(in: &self.cancellables)

        self.listener?.aspectRatioPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] ratio in
                guard let self else { return }
                self.currentAspectRatio = ratio
                self.updatePreviewLayout()
            })
            .store(in: &self.cancellables)
    }

    private func updatePreviewLayout() {
        guard let previewLayer else { return }

        let width = self.cameraPreview.bounds.width
        let height = width * self.currentAspectRatio.ratio

        previewLayer.frame = CGRect(
            x: 0,
            y: (self.cameraPreview.bounds.height - height) / 2,
            width: width,
            height: height
        )
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
