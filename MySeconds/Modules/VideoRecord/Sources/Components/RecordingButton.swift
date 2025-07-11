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

    // MARK: - properties

    private let progressPadding: CGFloat
    private var progressLayer: CAShapeLayer?
    private var didSetupLayer: Bool = false

    init(progressPadding: CGFloat = 5) {
        self.progressPadding = progressPadding

        super.init(frame: .zero)
        self.setupUI()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayer()
    }

    // MARK: - func

    private func setupUI() {
        self.backgroundColor = .red600
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.neutral950.cgColor
        shape.lineWidth = 3
        shape.lineCap = .round
        self.layer.addSublayer(shape)
        self.progressLayer = shape
    }

    private func setupLayer() {
        guard !self.didSetupLayer,
              let shape = progressLayer else { return }
        self.didSetupLayer = true
        layer.cornerRadius = bounds.height / 2
        let paddedBounds = bounds.insetBy(dx: -self.progressPadding, dy: -self.progressPadding)
        shape.frame = paddedBounds

        let radius = paddedBounds.width / 2
        let center = CGPoint(x: radius, y: radius)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        shape.path = path.cgPath
    }

    public func startProgressAnimation(duration: TimeInterval) {
        guard let shape = progressLayer else { return }
        shape.strokeStart = 0
        shape.strokeEnd = 1
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self else { return }
            self.progressLayer?.removeAnimation(forKey: "progress")
        }
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        shape.add(animation, forKey: "progress")
        CATransaction.commit()
    }

    public func cancelProgressAnimation() {
        self.progressLayer?.removeAnimation(forKey: "progress")
        self.progressLayer?.strokeStart = 0
        self.progressLayer?.strokeEnd = 1
    }
}
