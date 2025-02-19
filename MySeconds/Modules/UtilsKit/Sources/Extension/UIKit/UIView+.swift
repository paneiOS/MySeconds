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
}
