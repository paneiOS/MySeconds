//
//  RecordingControlView.swift
//  VideoRecord
//
//  Created by Chung Wussup on 5/25/25.
//

import Combine
import UIKit

import SnapKit

import ResourceKit

final class RecordControlView: UIView {

    private enum Constants {
        static let buttonSize: CGFloat = 48
        static let recordButtonSize: CGFloat = 54
        static let recordViewSize: CGFloat = 64
        static let horizontalInset: CGFloat = 24
        static let verticalInset: CGFloat = 16
        static let stackSpacing: CGFloat = 4
        static let albumCornerRadius: CGFloat = 8
        static let recordCornerRadius: CGFloat = 32
        static let recordButtonCornerRadius: CGFloat = 27
    }

    private let recordTapSubject = PassthroughSubject<Void, Never>()
    private let ratioTapSubject = PassthroughSubject<Void, Never>()
    private let timerTapSubject = PassthroughSubject<Void, Never>()
    private let flipTapSubject = PassthroughSubject<Void, Never>()
    private let albumTapSubject = PassthroughSubject<Void, Never>()

    var recordTapPublisher: AnyPublisher<Void, Never> {
        self.recordTapSubject.eraseToAnyPublisher()
    }

    var ratioTapPublisher: AnyPublisher<Void, Never> {
        self.ratioTapSubject.eraseToAnyPublisher()
    }

    var timerTapPublisher: AnyPublisher<Void, Never> {
        self.timerTapSubject.eraseToAnyPublisher()
    }

    var flipTapPublisher: AnyPublisher<Void, Never> {
        self.flipTapSubject.eraseToAnyPublisher()
    }

    var albumTapPublisher: AnyPublisher<Void, Never> {
        self.albumTapSubject.eraseToAnyPublisher()
    }

    private let recordView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.recordCornerRadius
        return view
    }()

    private let recordButton = RecordControlButton(
        type: .record,
        size: Constants.recordButtonSize,
        cornerRadius: Constants.recordButtonCornerRadius
    )

    private let ratioButton = RecordControlButton(
        type: .ratio,
        size: Constants.buttonSize,
        cornerRadius: Constants.buttonSize / 2
    )

    private let timerButton = RecordControlButton(
        type: .timer,
        size: Constants.buttonSize,
        cornerRadius: Constants.buttonSize / 2
    )

    private let cameraFlipButton = RecordControlButton(
        type: .flip,
        size: Constants.buttonSize,
        cornerRadius: Constants.buttonSize / 2
    )

    private let albumButton = RecordControlButton(
        type: .album,
        size: Constants.recordViewSize,
        cornerRadius: Constants.albumCornerRadius,
        borderColor: UIColor.neutral200,
        borderWidth: 1
    )

    private let albumCountLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .makeAttributedString(
            text: "0",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .neutral500
        )
        return label
    }()

    private var albumStack: UIStackView!
    private var rightVStack: UIStackView!
    private var buttonStack: UIStackView!

    private var cancellables = Set<AnyCancellable>()
    private var progressLayer: CAShapeLayer?

    private var maxAlbumCount: Int = 15

    var recordDuration: TimeInterval = 0 {
        didSet {
            self.progressLayer?.removeFromSuperlayer()
            self.progressLayer = nil
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.bind()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.progressLayer == nil {
            self.setupProgressLayer(duration: self.recordDuration)
        }
    }

    private func setupUI() {
        backgroundColor = .white

        self.albumStack = self.makeStack(
            arrangedSubviews: [self.albumButton, self.albumCountLabel],
            axis: .vertical,
            spacing: Constants.stackSpacing
        )

        self.albumButton.snp.makeConstraints {
            $0.size.equalTo(Constants.recordViewSize)
        }

        self.rightVStack = self.makeStack(
            arrangedSubviews: [self.ratioButton, self.cameraFlipButton],
            axis: .vertical,
            spacing: Constants.stackSpacing
        )

        self.buttonStack = self.makeStack(
            arrangedSubviews: [self.timerButton, self.rightVStack],
            axis: .horizontal,
            spacing: Constants.stackSpacing
        )

        addSubviews(self.albumStack, self.buttonStack, self.recordView)
        self.recordView.addSubview(self.recordButton)

        self.recordButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Constants.recordButtonSize)
        }

        self.albumStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Constants.horizontalInset)
            $0.centerY.equalToSuperview()
        }
        self.buttonStack.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Constants.horizontalInset)
            $0.top.bottom.equalToSuperview().inset(Constants.verticalInset)
        }
        self.recordView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Constants.recordViewSize)
        }

        self.albumCountLabel.text = "0 / \(self.maxAlbumCount)"
        self.setTimerButtonText(seconds: "3초")
    }

    private func bind() {
        let actions: [(UIButton, PassthroughSubject<Void, Never>)] = [
            (recordButton, recordTapSubject),
            (ratioButton, ratioTapSubject),
            (timerButton, timerTapSubject),
            (cameraFlipButton, flipTapSubject),
            (albumButton, albumTapSubject)
        ]

        for (button, subject) in actions {
            button
                .publisher(for: .touchUpInside)
                .map { _ in () }
                .subscribe(subject)
                .store(in: &self.cancellables)
        }
    }

    private func makeStack(
        arrangedSubviews: [UIView],
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat
    ) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = axis
        stack.alignment = .center
        stack.spacing = spacing
        return stack
    }

    private func setupProgressLayer(duration: TimeInterval) {
        self.progressLayer?.removeFromSuperlayer()
        let radius = Constants.recordViewSize / 2
        let center = CGPoint(x: radius, y: radius)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.neutral950.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        self.recordView.layer.addSublayer(layer)
        self.progressLayer = layer

        guard duration > 0 else { return }
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.progressLayer?.strokeEnd = 1
            self?.progressLayer?.removeAnimation(forKey: "progress")
        }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "progress")
        CATransaction.commit()
    }

    private func makeTimerAttributedText(seconds: String) -> NSAttributedString {
        let title = "촬영\n\(seconds)"
        let attributeStrings: [(String, [NSAttributedString.Key: Any])] = [
            ("촬영", [
                .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: UIColor.neutral500
            ]),
            (seconds, [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.neutral800
            ])
        ]
        return NSAttributedString.makeAttributedString(
            text: title,
            font: UIFont.systemFont(ofSize: 16, weight: .bold),
            textColor: .neutral800,
            lineBreakMode: .byWordWrapping,
            letterSpacingPercentage: 0,
            alignment: .center,
            additionalAttributes: attributeStrings
        )
    }

    func setTimerButtonText(seconds: String) {
        let attributed = self.makeTimerAttributedText(seconds: seconds)
        self.timerButton.setAttributedTitle(attributed, for: .normal)
    }

    func setRatioButtonText() {
        let next = (ratioButton.currentTitle == "1:1") ? "4:3" : "1:1"
        self.ratioButton.setTitle(next, for: .normal)
    }

    func setRecordingState(_ isRecording: Bool) {
        self.albumStack.isHidden = isRecording
        self.buttonStack.isHidden = isRecording
    }

    func updateAlbum(thumbnail: UIImage?, count: Int) {
        self.albumButton.setImage(thumbnail, for: .normal)
        self.albumCountLabel.text = "\(count) / \(self.maxAlbumCount)"

        if count == self.maxAlbumCount {
            self.albumCountLabel.textColor = .red500
        }
    }
}
