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
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private let bubbleLayer = CAShapeLayer()

    /// 주어진 텍스트로 툴팁을 초기화.
    /// - Parameter text: 말풍선 안에 표시할 메시지
    public init(text: String) {
        super.init(frame: .zero)
        self.commonInit()
        self.textLabel.text = text
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .clear
        isHidden = true
        layer.addSublayer(self.bubbleLayer)
        addSubview(self.textLabel)

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
}
