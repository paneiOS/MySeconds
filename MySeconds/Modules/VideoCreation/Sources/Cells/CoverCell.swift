//
//  CoverCell.swift
//  VideoCreation
//
//  Created by 이정환 on 5/4/25.
//

import UIKit

import ResourceKit
import UtilsKit

final class CoverCell: UICollectionViewCell {
    static let reuseID = "CoverCell"

    private let stackView: UIStackView = {
        let view: UIStackView = .init()
        view.axis = .vertical
        view.spacing = 4
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: ResourceKitAsset.plus.image)
        imageView.clipsToBounds = true

        return imageView
    }()

    private let label: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.applyDynamicDashedBorder(color: .neutral300)
    }

    private func setupUI() {
        self.backgroundColor = .neutral50

        for item in [self.imageView, self.label] {
            self.stackView.addArrangedSubview(item)
        }
    }
}
