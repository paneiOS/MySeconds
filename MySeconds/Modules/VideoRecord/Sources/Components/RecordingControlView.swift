//
//  RecordingControlView.swift
//  VideoRecord
//
//  Created by Chung Wussup on 5/25/25.
//

import Combine
import UIKit

import SnapKit

import MySecondsKit
import ResourceKit
import SharedModels
import VideoDraftStorage

final class RecordingControlView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let recordButtonSize: CGFloat = 54
        static let secondaryButtonSize: CGFloat = 48
        static let horizontalInset: CGFloat = 24
        static let verticalInset: CGFloat = 16
        static let stackSpacing: CGFloat = 4
    }

    // MARK: - UI Properties

    private let recordingButton: RecordingButton = .init(progressPadding: 5)

    private lazy var ratioButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = Constants.secondaryButtonSize / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.neutral200.cgColor
        return button
    }()

    private lazy var timerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = Constants.secondaryButtonSize / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.neutral200.cgColor
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        return button
    }()

    private lazy var cameraFlipButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = Constants.secondaryButtonSize / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.neutral200.cgColor
        let image = ResourceKitAsset.refreshCcw.image.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .neutral950
        return button
    }()

    private let albumControlView: UIControl = {
        let control: UIControl = .init()
        control.backgroundColor = .neutral100
        control.clipsToBounds = true
        control.layer.cornerRadius = 8
        control.layer.borderWidth = 1
        control.layer.borderColor = UIColor.neutral200.cgColor
        return control
    }()

    private let albumThumbnailView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.tintColor = .neutral300
        return imageView
    }()

    private let albumCountLabel: UILabel = .init()

    private let tooltipView = TooltipView()

    private let albumStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing
        return stack
    }()

    private let secondaryButtonView: UIView = .init()

    // MARK: - Properties

    private let recordTapSubject = PassthroughSubject<Void, Never>()
    var recordTapPublisher: AnyPublisher<Void, Never> {
        self.recordTapSubject.eraseToAnyPublisher()
    }

    private let ratioTapSubject = PassthroughSubject<Void, Never>()
    var ratioTapPublisher: AnyPublisher<Void, Never> {
        self.ratioTapSubject.eraseToAnyPublisher()
    }

    private let timerTapSubject = PassthroughSubject<Void, Never>()
    var timerTapPublisher: AnyPublisher<Void, Never> {
        self.timerTapSubject.eraseToAnyPublisher()
    }

    private let flipTapSubject = PassthroughSubject<Void, Never>()
    var flipTapPublisher: AnyPublisher<Void, Never> {
        self.flipTapSubject.eraseToAnyPublisher()
    }

    private let albumTapSubject = PassthroughSubject<Void, Never>()
    var albumTapPublisher: AnyPublisher<Void, Never> {
        self.albumTapSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private var progressLayer: CAShapeLayer?
    private var time: TimeInterval?

    override public init(frame: CGRect) {

        super.init(frame: frame)
        self.setupUI()
        self.bind()
    }

    required init?(coder: NSCoder) { nil }

    private func setupUI() {
        self.backgroundColor = .white
        self.addSubviews(self.albumStack, self.recordingButton, self.secondaryButtonView)

        self.albumStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constants.horizontalInset)
            $0.centerY.equalToSuperview()
        }
        for item in [self.albumControlView, self.albumCountLabel] {
            self.albumStack.addArrangedSubview(item)
        }
        self.albumControlView.snp.makeConstraints {
            $0.size.equalTo(Constants.recordButtonSize)
        }

        self.albumControlView.addSubview(self.albumThumbnailView)
        self.albumThumbnailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.recordingButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Constants.recordButtonSize)
        }

        self.secondaryButtonView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(24)
        }
        self.secondaryButtonView.addSubviews(self.timerButton, self.ratioButton, self.cameraFlipButton)
        self.timerButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(Constants.secondaryButtonSize)
        }
        self.ratioButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(self.timerButton.snp.trailing)
            $0.size.equalTo(Constants.secondaryButtonSize)
        }
        self.cameraFlipButton.snp.makeConstraints {
            $0.top.equalTo(self.ratioButton.snp.bottom).offset(8)
            $0.leading.equalTo(self.timerButton.snp.trailing)
            $0.bottom.trailing.equalToSuperview()
            $0.size.equalTo(Constants.secondaryButtonSize)
        }

        self.addSubview(self.tooltipView)
        self.tooltipView.snp.makeConstraints {
            $0.centerX.equalTo(self.recordingButton)
            $0.bottom.equalTo(self.recordingButton.snp.top).offset(-8)
        }
    }

    private func bind() {
        self.recordingButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.recordTapSubject.send()
            })
            .store(in: &self.cancellables)

        self.ratioButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.ratioTapSubject.send()
            })
            .store(in: &self.cancellables)

        self.timerButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.timerTapSubject.send()
            })
            .store(in: &self.cancellables)

        self.cameraFlipButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.flipTapSubject.send()
            })
            .store(in: &self.cancellables)

        self.albumControlView.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.albumTapSubject.send()
            })
            .store(in: &self.cancellables)
    }
}

extension RecordingControlView {
    func setTimer(time: TimeInterval) {
        self.time = time
        self.setTimerButtonText(text: "\(Int(time))")
    }

    private func setTimerButtonText(text: String) {
        let title = "촬영\n\(text)초"
        let attributeStrings: [(String, [NSAttributedString.Key: Any])] = [
            ("촬영", [
                .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: UIColor.neutral500
            ]),
            (text, [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.neutral800
            ]),
            (text: "초", attribute: [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor.neutral800
            ])
        ]
        self.timerButton.setAttributedTitle(
            .makeAttributedString(
                text: title,
                font: UIFont.systemFont(ofSize: 16, weight: .bold),
                textColor: .neutral800,
                lineBreakMode: .byWordWrapping,
                letterSpacingPercentage: 0,
                alignment: .center,
                additionalAttributes: attributeStrings
            ),
            for: .normal
        )
    }

    func setRatioButtonText(text: String) {
        let attributedText = NSAttributedString.makeAttributedString(
            text: text,
            font: .systemFont(ofSize: 16),
            textColor: .neutral950
        )
        self.ratioButton.setAttributedTitle(attributedText, for: .normal)
    }

    func setThumbnail(image: UIImage?) {
        if let image {
            self.albumThumbnailView.contentMode = .scaleAspectFill
            self.albumThumbnailView.image = image
        } else {
            self.albumThumbnailView.contentMode = .center
            self.albumThumbnailView.image = ResourceKitAsset.loader.image
                .resized(to: CGSize(width: 32, height: 32))
                .withRenderingMode(.alwaysTemplate)
        }
    }

    func setAlbumCountText(currentCount: Int, maxCount: Int) {
        let isPhotoCapturable: Bool = currentCount <= maxCount
        guard isPhotoCapturable else { return }
        self.albumCountLabel.attributedText = .makeAttributedString(
            text: "\(currentCount) / \(maxCount)",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: isPhotoCapturable ? .neutral500 : .red500
        )
        self.secondaryButtonView.alpha = isPhotoCapturable ? 1.0 : 0.5
        self.recordingButton.alpha = isPhotoCapturable ? 1.0 : 0.5
        self.progressLayer?.opacity = isPhotoCapturable ? 1.0 : 0.5
        if isPhotoCapturable {
            self.tooltipView.hide()
        } else {
            self.tooltipView.show(
                self,
                text: "최대 컷에 도달했어요\n컷을 삭제하거나 만들기를 진행해주세요"
            )
        }
    }

    func updateRecordingState(_ isRecording: Bool) {
        guard let time else { return }
        self.albumStack.isHidden = isRecording
        self.secondaryButtonView.isHidden = isRecording
        if isRecording {
            self.recordingButton.startProgressAnimation(duration: time)
        } else {
            self.recordingButton.cancelProgressAnimation()
        }
    }
}
