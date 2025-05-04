//
//  CoverClipCell.swift
//  VideoCreation
//
//  Created by 이정환 on 5/4/25.
//

import UIKit

import ResourceKit
import UtilsKit

final class CoverClipCell: UICollectionViewCell {
    private let stackView: UIStackView = {
        let view: UIStackView = .init()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .center
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: ResourceKitAsset.plus.image)
        imageView.contentMode = .center
        imageView.tintColor = .neutral400
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
        self.contentView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        for item in [self.imageView, self.label] {
            self.stackView.addArrangedSubview(item)
        }

        self.imageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
    }

    func drawCell(data: CoverClip) {
        self.label.attributedText = .makeAttributedString(
            text: data.type.rawValue,
            font: .systemFont(ofSize: 12, weight: .medium),
            textColor: .neutral400,
            alignment: .center
        )
    }
}
