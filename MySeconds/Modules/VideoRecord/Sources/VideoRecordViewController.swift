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

    private let cameraControlView: UIView = .init()
    private let albumCountLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "0 / 15",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .neutral500
        )
        return label
    }()

    private let recordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 27
        button.backgroundColor = .red600
        return button
    }()

    private let ratioButton: UIButton = {
        let button = UIButton()
        let size: CGFloat = 48
        button.setTitle("1:1", for: .normal)
        button.setTitleColor(.neutral950, for: .normal)
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = size / 2
        button.layer.borderColor = UIColor.neutral200.cgColor
        button.layer.borderWidth = 1
        button.snp.makeConstraints { $0.size.equalTo(size) }
        return button
    }()

    private let timerButton: UIButton = {
        let button = UIButton()
        let size: CGFloat = 48
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = size / 2
        button.layer.borderColor = UIColor.neutral200.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.snp.makeConstraints { $0.size.equalTo(size) }
        return button
    }()

    private let cameraFlipButton: UIButton = {
        let button = UIButton()
        let size: CGFloat = 48
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = size / 2
        button.layer.borderColor = UIColor.neutral200.cgColor
        button.layer.borderWidth = 1
        button.setImage(ResourceKitAsset.refreshCcw.image, for: .normal)
        button.tintColor = .neutral950
        button.snp.makeConstraints { $0.size.equalTo(size) }
        return button
    }()

    private let albumView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral100
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.neutral200.cgColor
        return view
    }()

    private let recordView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        return view
    }()

    private var cameraPreview: UIView = .init()
    private let permissionView = CameraPermissionView()
    private lazy var cameraManager: CameraManagerProtocol = CameraManager()

    private var progressLayer: CAShapeLayer?

    override func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubviews(self.cameraControlView, self.cameraPreview)

        let albumStackView = self.createStackView(arrangedSubviews: [self.albumView, self.albumCountLabel], axis: .vertical)
        let buttonStackView = self.createButtonStackView()

        self.cameraControlView.addSubviews(albumStackView, buttonStackView, self.recordView)
        self.recordView.addSubview(self.recordButton)

        self.albumView.snp.makeConstraints {
            $0.size.equalTo(64)
        }

        self.cameraControlView.snp.makeConstraints {
            $0.height.equalTo(136)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.recordButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(54)
        }

        self.recordView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(64)
        }

        albumStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }

        buttonStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview().inset(16)
        }

        self.cameraPreview.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(62)
            $0.bottom.equalTo(self.cameraControlView.snp.top).offset(-62)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        self.cameraManager.delegate = self
        self.cameraManager.configurePreview(in: self.cameraPreview, cornerRadius: 32)
        self.cameraManager.requestAuthorizationAndStart()
    }

    override func bind() {
        self.recordButton
            .publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }

                if self.cameraManager.isRecording {
                    self.cameraManager.toggleRecording()
                } else {
                    let duration = Double(self.cameraManager.recordingDurationText.dropLast(1)) ?? 3
                    self.setupProgressLayer(duration: duration)
                    self.cameraManager.toggleRecording()
                }
            })
            .store(in: &cancellables)

        self.ratioButton
            .publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.cameraManager.toggleAspectRatio()
                let nextTitle = (self.ratioButton.currentTitle == "1:1") ? "4:3" : "1:1"
                self.ratioButton.setTitle(nextTitle, for: .normal)
            })
            .store(in: &cancellables)

        self.timerButton
            .publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.cameraManager.toggleDuration()
                let seconds = self.cameraManager.recordingDurationText

                self.timerButton.setAttributedTitle(
                    self.makeTimerAttributedText(seconds: seconds),
                    for: .normal
                )
            })
            .store(in: &cancellables)

        self.cameraFlipButton
            .publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.cameraManager.switchCamera()
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

    private func setupProgressLayer(duration: TimeInterval) {
        self.progressLayer?.removeFromSuperlayer()

        let radius = self.recordView.bounds.width / 2
        let center = CGPoint(x: recordView.bounds.midX, y: self.recordView.bounds.midY)
        let circlePath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )

        let layer = CAShapeLayer()
        layer.path = circlePath.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.neutral950.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.strokeEnd = 1

        self.recordView.layer.addSublayer(layer)
        self.progressLayer = layer

        guard duration > 0 else { return }

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let layer = self?.progressLayer else { return }
            layer.strokeEnd = 1
            layer.removeAnimation(forKey: "progress")
        }

        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = duration
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        layer.add(anim, forKey: "progress")

        CATransaction.commit()
    }

    private func createStackView(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func createButtonStackView() -> UIStackView {
        let initialSeconds = self.cameraManager.recordingDurationText
        self.timerButton.setAttributedTitle(self.makeTimerAttributedText(seconds: initialSeconds), for: .normal)

        let vStackView = self.createStackView(arrangedSubviews: [self.ratioButton, self.cameraFlipButton], axis: .vertical)
        let hStackView = self.createStackView(arrangedSubviews: [self.timerButton, vStackView], axis: .horizontal)

        return hStackView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.cameraPreview.layoutIfNeeded()
        self.cameraManager.updatePreviewLayout()

        self.recordView.layoutIfNeeded()

        if self.progressLayer == nil {
            self.setupProgressLayer(duration: 0)
        }
    }

    private func makeTimerAttributedText(seconds: String) -> NSAttributedString {
        let title = "촬영\n\(seconds)"
        let additional: [(text: String, attribute: [NSAttributedString.Key: Any])] = [
            (
                text: "촬영",
                attribute: [
                    .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                    .foregroundColor: UIColor.neutral500
                ]
            ),
            (
                text: seconds,
                attribute: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                    .foregroundColor: UIColor.neutral800
                ]
            )
        ]

        let attributed = NSAttributedString.makeAttributedString(
            text: title,
            font: UIFont.systemFont(ofSize: 16, weight: .bold),
            textColor: .neutral800,
            lineBreakMode: .byWordWrapping,
            letterSpacingPercentage: 0,
            alignment: .center,
            additionalAttributes: additional
        )
        return attributed
    }
}

//TODO: 테스트를 위해 앨범 저장 처리 추후 제거
import Photos

extension VideoRecordViewController: CameraManagerDelegate {

    func cameraManager(_ manager: CameraManager, didStartRecording url: URL) {}

    func cameraManager(_ manager: CameraManager, didFinishRecording url: URL, error: (any Error)?) {
        if let error {
            print("녹화 실패:", error)
            return
        }

        
        //TODO: 테스트를 위해 앨범 저장 처리 추후 제거
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
            self.cameraPreview.addSubview(self.permissionView)
            self.permissionView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
}
