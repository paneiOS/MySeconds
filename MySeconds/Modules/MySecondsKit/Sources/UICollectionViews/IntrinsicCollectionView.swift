//
//  IntrinsicCollectionView.swift
//  MySecondsKit
//
//  Created by 이정환 on 5/8/25.
//

import UIKit

public final class IntrinsicCollectionView: UICollectionView {
    override public var intrinsicContentSize: CGSize {
        contentSize
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        invalidateIntrinsicContentSize()
    }
}
