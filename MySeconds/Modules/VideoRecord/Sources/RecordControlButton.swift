//
//  RecordControlButton.swift
//  VideoRecord
//
//  Created by Chung Wussup on 5/21/25.
//

import UIKit

import ResourceKit

final class RecordControlButton: UIButton {
    enum ButtonType {
        case record, ratio, timer, flip, album
    }

    init(
        type: ButtonType,
        size: CGFloat,
        cornerRadius: CGFloat,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 0
    ) {
        super.init(frame: .zero)

        layer.cornerRadius = cornerRadius
        if let borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
        }

        snp.makeConstraints {
            $0.size.equalTo(size)
        }

        switch type {
        case .record:
            backgroundColor = .red600

        case .ratio:
            backgroundColor = .neutral100
            setTitle("1:1", for: .normal)
            setTitleColor(.neutral950, for: .normal)

        case .timer:
            backgroundColor = .neutral100
            titleLabel?.numberOfLines = 2
            titleLabel?.textAlignment = .center

        case .flip:
            backgroundColor = .neutral100
            setImage(ResourceKitAsset.refreshCcw.image, for: .normal)
            tintColor = .neutral950

        case .album:
            backgroundColor = .neutral100
            imageView?.contentMode = .scaleAspectFill
            clipsToBounds = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
