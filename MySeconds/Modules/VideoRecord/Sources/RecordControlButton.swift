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
                48
            case .ratio, .timer, .flip:
                58
            case .album:
                64
            }
        }

        var buttonRadius: CGFloat {
            switch self {
            case .record:
                24
            case .ratio, .timer, .flip:
                27
            case .album:
                8
            }
        }
    }

    init(
        type: ButtonType
    ) {
        super.init(frame: .zero)

        switch type {
        case .record:

            backgroundColor = .red600
            layer.cornerRadius = type.buttonRadius

            snp.makeConstraints {
                $0.size.equalTo(type.buttonSize)
            }

        case .ratio:
            backgroundColor = .neutral100
            setTitle("1:1", for: .normal)
            setTitleColor(.neutral950, for: .normal)
            layer.cornerRadius = type.buttonRadius

            snp.makeConstraints {
                $0.size.equalTo(type.buttonSize)
            }

        case .timer:
            backgroundColor = .neutral100
            titleLabel?.numberOfLines = 2
            titleLabel?.textAlignment = .center
            layer.cornerRadius = type.buttonRadius

            snp.makeConstraints {
                $0.size.equalTo(type.buttonSize)
            }

        case .flip:
            backgroundColor = .neutral100
            setImage(ResourceKitAsset.refreshCcw.image, for: .normal)
            tintColor = .neutral950
            layer.cornerRadius = type.buttonRadius

            snp.makeConstraints {
                $0.size.equalTo(type.buttonSize)
            }

        case .album:
            backgroundColor = .neutral100
            imageView?.contentMode = .scaleAspectFill
            clipsToBounds = true
            layer.cornerRadius = type.buttonRadius

            layer.borderColor = UIColor.neutral200.cgColor
            layer.borderWidth = 1
            snp.makeConstraints {
                $0.size.equalTo(type.buttonSize)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
