//
//  UIImageView+.swift
//  UtilsKit
//
//  Created by 이정환 on 5/8/25.
//

import UIKit

public extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
