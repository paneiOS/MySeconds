//
//  UIView+.swift
//  UtilsKit
//
//  Created by JeongHwan Lee on 1/26/25.
//

import UIKit

public extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }

    func applyShadow(
        color: UIColor = .black,
        x: CGFloat = 0,
        y: CGFloat = 0,
        blur: CGFloat = 0,
        spread: CGFloat = 0
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2.0

        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let rect = bounds.insetBy(dx: -spread, dy: -spread)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    func applyDynamicDashedBorder(
        color: UIColor,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 8,
        approxSegment: CGFloat = 8
    ) {
        layer.sublayers?
            .filter { $0.name?.hasPrefix("dynamicDash_") ?? false }
            .forEach { $0.removeFromSuperlayer() }

        let (dash, gap) = computeDashLengths(
            for: bounds,
            cornerRadius: cornerRadius,
            desiredApproxSegment: approxSegment
        )

        let borderLayer = CAShapeLayer()
        borderLayer.name = "dynamicDash_border"
        borderLayer.strokeColor = color.cgColor
        borderLayer.fillColor = nil
        borderLayer.lineWidth = lineWidth
        borderLayer.lineDashPattern = [dash, gap]
        borderLayer.lineCap = .butt

        let rectInset = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: rectInset, cornerRadius: cornerRadius - lineWidth / 2).cgPath
        layer.addSublayer(borderLayer)

        func computeDashLengths(for bounds: CGRect, cornerRadius: CGFloat, desiredApproxSegment: CGFloat) -> (dash: NSNumber, gap: NSNumber) {
            let straight = (bounds.width + bounds.height) * 2 - 8 * cornerRadius
            let cornerPerimeter = 2 * .pi * cornerRadius
            let totalPerimeter = straight + cornerPerimeter
            let segmentsFloat = totalPerimeter / desiredApproxSegment
            let segmentsRounded = round(segmentsFloat)
            let actualSegment = totalPerimeter / segmentsRounded
            let dashLength = actualSegment / 2

            return (
                NSNumber(value: Double(dashLength)),
                NSNumber(value: Double(dashLength))
            )
        }
    }
}
