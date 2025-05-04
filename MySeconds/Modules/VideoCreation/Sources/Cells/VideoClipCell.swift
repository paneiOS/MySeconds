//
//  VideoClipCell.swift
//  VideoCreation
//
//  Created by 이정환 on 5/5/25.
//

import UIKit

import ResourceKit
import UtilsKit

final class VideoClipCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.applyDynamicDashedBorder(color: .neutral300)
    }

    private func setupUI() {}

    func drawCell(data: VideoClip) {}
}
