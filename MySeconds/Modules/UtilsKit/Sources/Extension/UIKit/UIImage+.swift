//
//  UIImage+.swift
//  UtilsKit
//
//  Created by Chung Wussup on 5/13/25.
//

import UIKit

public extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
