//
//  CircleBorderButton.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 6/24/25.
//

import UIKit

import ResourceKit

public final class CircleBorderButton: UIButton {
    public enum ButtonStyle {
        case image(image: UIImage, tintColor: UIColor = UIColor.neutral950)
        case attributeText(attributedString: NSAttributedString)
    }

    public init(
        style: ButtonStyle,
        size: CGFloat,
        backgroundColor: UIColor = .neutral100,
        borderWidth: CGFloat = 1,
        borderColor: UIColor = UIColor.neutral200,
        configuration: UIButton.Configuration = .plain()
    ) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = size / 2
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center
        self.setupUI(buttonStyle: style)
    }

    required init?(coder: NSCoder) { nil }

    private func setupUI(buttonStyle: ButtonStyle) {
        switch buttonStyle {
        case let .image(image, tintColor):
            self.setImage(image, for: .normal)
            self.tintColor = tintColor
        case let .attributeText(attributedString):
            self.setAttributedTitle(attributedString, for: .normal)
        }
    }
}
