//
//  UIView+.swift
//  UtilsKit
//
//  Created by JeongHwan Lee on 1/26/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}
