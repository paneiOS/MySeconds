//
//  TooltipView.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/26/25.
//

import UIKit

import SnapKit

public final class TooltipView: UIView {
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let bubbleLayer = CAShapeLayer()

    override public init(frame: CGRect) {
        super.init(frame: .zero)
        self.commonInit()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        self.backgroundColor = .clear
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.layer.addSublayer(self.bubbleLayer)
        self.addSubview(self.textLabel)

        self.textLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.drawBubblePath()
    }

    private func drawBubblePath() {
        let width = bounds.width
        let height = bounds.height
        let radius: CGFloat = 6
        let tailHeight: CGFloat = 8
        let tailWidth: CGFloat = 16

        let path = UIBezierPath()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: width - radius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: width - radius, y: radius),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: width, y: height - tailHeight - radius))
        path.addArc(
            withCenter: CGPoint(x: width - radius, y: height - tailHeight - radius),
            radius: radius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        let midX = width / 2
        path.addLine(to: CGPoint(x: midX + tailWidth / 2, y: height - tailHeight))
        path.addLine(to: CGPoint(x: midX, y: height))
        path.addLine(to: CGPoint(x: midX - tailWidth / 2, y: height - tailHeight))
        path.addLine(to: CGPoint(x: radius, y: height - tailHeight))
        path.addArc(
            withCenter: CGPoint(x: radius, y: height - tailHeight - radius),
            radius: radius,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(
            withCenter: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .pi,
            endAngle: -.pi / 2,
            clockwise: true
        )
        path.close()

        self.bubbleLayer.path = path.cgPath
        self.bubbleLayer.fillColor = UIColor.neutral800.cgColor
    }

    public func show(_ parentView: UIView, standardView: UIView, text: String, animated: Bool = false) {
        guard superview == nil else { return }

        parentView.addSubview(self)

        self.snp.makeConstraints {
            $0.centerX.equalTo(standardView)
            $0.bottom.equalTo(standardView.snp.top).offset(-8)
        }

        self.textLabel.text = text

        self.layoutIfNeeded()

        let showAnimation = {
            self.alpha = 1
            self.transform = .identity
        }

        if animated {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.8,
                options: [.curveEaseOut],
                animations: showAnimation
            )
        } else {
            showAnimation()
        }
    }

    public func hide(animated: Bool = true) {
        guard superview != nil else { return }

        let hiddenAnimation = {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 0
        }

        let completion: (Bool) -> Void = { _ in
            self.removeFromSuperview()
            self.transform = .identity
        }

        if animated {
            UIView.animate(
                withDuration: 0.2,
                animations: hiddenAnimation,
                completion: completion
            )
        } else {
            hiddenAnimation()
            completion(true)
        }
    }
}
