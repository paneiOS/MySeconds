//
//  RecordingButton.swift
//  VideoRecord
//
//  Created by Chung Wussup on 6/13/25.
//

import Combine
import UIKit

import SnapKit

import ResourceKit

final class RecordingButton: UIButton {
    private let buttonSize: CGFloat
    private let progressPadding: CGFloat
    private var progressLayer: CAShapeLayer?

    /// - Parameters:
    ///   - buttonSize: 버튼의 정사각형 가로 길이
    ///   - progressPadding: 버튼 둘레에 추가로 남길 여백 (예: 5일 경우 전체 프로그레스 원은 buttonSize + 2*5)
    init(buttonSize: CGFloat = 54, progressPadding: CGFloat = 5) {
        self.buttonSize = buttonSize
        self.progressPadding = progressPadding

        super.init(frame: .zero)

        self.commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var recordDuration: TimeInterval = 0 {
        didSet {
            self.progressLayer?.removeFromSuperlayer()
            self.progressLayer = nil
            self.setupProgressLayer(duration: self.recordDuration)
        }
    }

    private func commonInit() {
        self.backgroundColor = .red600

        self.layer.cornerRadius = self.buttonSize / 2

        self.snp.makeConstraints {
            $0.size.equalTo(self.buttonSize)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.progressLayer == nil {
            self.setupProgressLayer(duration: self.recordDuration)
        }
    }

    public func changeDuration(duration: TimeInterval) {
        self.recordDuration = duration
    }

    private func setupProgressLayer(duration: TimeInterval) {
        let progressSize = self.buttonSize + 2 * self.progressPadding
        let padding = self.progressPadding

        let layerFrame = CGRect(
            x: -padding,
            y: -padding,
            width: progressSize,
            height: progressSize
        )

        let radius = progressSize / 2
        let center = CGPoint(x: radius, y: radius)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )

        let shape = CAShapeLayer()
        shape.frame = layerFrame
        shape.path = path.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.neutral950.cgColor
        shape.lineWidth = 3
        shape.lineCap = .round

        self.layer.addSublayer(shape)
        self.progressLayer = shape

        guard duration > 0 else { return }
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self else { return }
            self.progressLayer?.strokeEnd = 1
            self.progressLayer?.removeAnimation(forKey: "progress")
        }

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        shape.add(animation, forKey: "progress")
        CATransaction.commit()
    }
}
