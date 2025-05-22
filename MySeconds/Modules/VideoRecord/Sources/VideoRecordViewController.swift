//
//  VideoRecordViewController.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import AVFoundation
import Combine
import CoreMedia
import UIKit

import BaseRIBsKit
import SnapKit

import MySecondsKit
import ResourceKit

protocol VideoRecordPresentableListener: AnyObject {}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, NavigationConfigurable {

    weak var listener: VideoRecordPresentableListener?

    private let recordControlView = RecordControlView()

    private var cameraPreview: UIView = .init()
    private let permissionView = CameraPermissionView()
    private lazy var cameraManager: CameraManagerProtocol = CameraManager()

    override func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubviews(self.recordControlView, self.cameraPreview)

        self.recordControlView.snp.makeConstraints {
            $0.height.equalTo(136)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.cameraPreview.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(62)
            $0.bottom.equalTo(self.recordControlView.snp.top).offset(-62)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        self.cameraManager.delegate = self
        self.cameraManager.configurePreview(in: self.cameraPreview, cornerRadius: 32)
        self.cameraManager.requestAuthorizationAndStart()
    }

    override func bind() {
        self.recordControlView.recordTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }

                if self.cameraManager.isRecording {
                    self.cameraManager.toggleRecording()
                } else {
                    let duration = Double(self.cameraManager.recordingDurationText.dropLast(1)) ?? 3
                    self.recordControlView.recordDuration = duration
                    self.cameraManager.toggleRecording()
                }
            })
            .store(in: &cancellables)

        self.recordControlView.flipTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.cameraManager.switchCamera()
            })
            .store(in: &cancellables)

        self.recordControlView.ratioTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.cameraManager.toggleAspectRatio()
                self.recordControlView.setRatioButtonText()
            })
            .store(in: &cancellables)

        self.recordControlView.timerTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.cameraManager.toggleDuration()
                let seconds = self.cameraManager.recordingDurationText
                self.recordControlView.setTimerButtonText(seconds: seconds)
            })
            .store(in: &cancellables)

        self.recordControlView.albumTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                print("Tap Album Button")
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.cameraPreview.layoutIfNeeded()
        self.cameraManager.updatePreviewLayout()

        self.recordControlView.layoutIfNeeded()
    }
}

// TODO: 테스트를 위해 앨범 저장 처리 추후 제거
import Photos

extension VideoRecordViewController: CameraManagerDelegate {

    func cameraManager(_ manager: CameraManager, didStartRecording url: URL) {
        DispatchQueue.main.async {
            self.recordControlView.setRecordingState(true)
        }
    }

    func cameraManager(_ manager: CameraManager, didFinishRecording url: URL, error: (any Error)?) {
        if let error {
            print("녹화 실패:", error)
            return
        }

        DispatchQueue.main.async {
            self.recordControlView.setRecordingState(false)
        }

        // TODO: 테스트를 위해 앨범 저장 처리 추후 제거
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("포토 라이브러리 접근 거부됨")
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, saveError in
                DispatchQueue.main.async {
                    if success {
                        print("비디오가 앨범에 저장되었습니다.")
                    } else {
                        print("저장 실패:", saveError ?? "알 수 없는 오류")
                    }
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }
    }

    func cameraManagerDidFailAuthorization(_ manager: CameraManager) {
        DispatchQueue.main.async {
            self.recordControlView.setRecordingState(false)
            self.cameraPreview.addSubview(self.permissionView)
            self.permissionView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
}
