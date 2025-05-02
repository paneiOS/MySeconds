//
//  String+.swift
//  UtilsKit
//
//  Created by 이정환 on 4/24/25.
//

import UIKit

public extension NSAttributedString {
    static func makeAttributedString(
        text: String,
        font: UIFont,
        textColor: UIColor = .black,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail,
        letterSpacingPercentage: CGFloat = -2.0,
        alignment: NSTextAlignment = .left,
        additionalAttributes: [(text: String, attribute: [NSAttributedString.Key: Any])]? = nil
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: textColor,
            .kern: font.pointSize * letterSpacingPercentage / 100.0
        ]
        if let additionalAttributes {
            let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
            for additionalAttribute in additionalAttributes {
                let range = (text as NSString).range(of: additionalAttribute.text)
                attributedString.addAttributes(additionalAttribute.attribute, range: range)
            }
            return attributedString
        }
        return .init(string: text, attributes: baseAttributes)
    }
}
