//
//  RecordControlButton.swift
//  VideoRecord
//
//  Created by Chung Wussup on 5/25/25.
//

import UIKit

import SnapKit

import ResourceKit

final class RecordControlButton: UIButton {
    enum ButtonType {
        case record, ratio, timer, flip, album

        var buttonSize: CGFloat {
            switch self {
            case .record:
                54
            case .ratio, .timer, .flip:
                48
            case .album:
                64
            }
        }

        var buttonRadius: CGFloat {
            switch self {
            case .album:
                8
            default:
                self.buttonSize / 2
            }
        }
    }

    private let type: ButtonType

    init(type: ButtonType) {
        self.type = type
        super.init(frame: .zero)
        self.setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let dimension = self.type.buttonSize
        return CGSize(width: dimension, height: dimension)
    }

    private func setupUI() {
        layer.cornerRadius = self.type.buttonRadius

        switch self.type {
        case .record:
            backgroundColor = .red600
        case .ratio:
            backgroundColor = .neutral100
            setTitle("1:1", for: .normal)
            setTitleColor(.neutral950, for: .normal)
            self.setupLayerBorder()
        case .timer:
            backgroundColor = .neutral100
            titleLabel?.numberOfLines = 2
            titleLabel?.textAlignment = .center
            self.setupLayerBorder()
        case .flip:
            backgroundColor = .neutral100
            setImage(ResourceKitAsset.refreshCcw.image, for: .normal)
            tintColor = .neutral950
            self.setupLayerBorder()
        case .album:
            backgroundColor = .neutral100
            imageView?.contentMode = .scaleAspectFill
            clipsToBounds = true
            self.setupLayerBorder()
        }
    }

    private func setupLayerBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.neutral200.cgColor
    }
}
