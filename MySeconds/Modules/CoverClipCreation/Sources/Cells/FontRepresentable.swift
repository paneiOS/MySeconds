//
//  FontRepresentable.swift
//  CoverClipCreation
//
//  Created by 이정환 on 5/20/25.
//

import UIKit

protocol FontRepresentable {
    func font(of size: CGFloat, weight: UIFont.Weight) -> UIFont
    var displayName: String { get }
}

enum CustomFont: String, CaseIterable, FontRepresentable {
    case dungGeunMo = "DungGeunMo"
    case inklipquid = "THEFACESHOP"
    case samulnoriMedium = "CallifontSamulnori-Medium"
    case parkdahyun = "Ownglyph_PDH-Rg"
    case yCloverRegular = "YClover-Regular"

    func font(of size: CGFloat, weight: UIFont.Weight) -> UIFont {
        UIFont(name: rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }

    var displayName: String {
        let ctFont = CTFontCreateWithName(rawValue as CFString, 12, nil)
        guard let name = CTFontCopyName(ctFont, kCTFontFullNameKey) as String? else {
            return rawValue
        }
        return name
    }
}

extension UIFont: FontRepresentable {
    func font(of size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let descriptor = self.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: weight
            ]
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    var displayName: String { "기본" }
}
