//
//  FontCell.swift
//  CoverClipCreation
//
//  Created by 이정환 on 5/20/25.
//

import UIKit

import SnapKit

import ResourceKit
import UtilsKit

final class FontCell: UICollectionViewCell {
    private let label: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderColor = UIColor.neutral200.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.masksToBounds = true

        self.contentView.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.leading.trailing.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    override var isSelected: Bool {
        didSet {
            guard let attributedText = label.attributedText else { return }
            contentView.backgroundColor = self.isSelected ? UIColor.black : UIColor.clear
            let mutable = NSMutableAttributedString(attributedString: attributedText)
            mutable.addAttribute(
                .foregroundColor,
                value: self.isSelected ? UIColor.white : UIColor.black,
                range: NSRange(location: 0, length: mutable.length)
            )
            self.label.attributedText = mutable
        }
    }

    func drawCell(represent: FontRepresentable) {
        contentView.backgroundColor = self.isSelected ? UIColor.black : UIColor.clear
        self.label.attributedText = .makeAttributedString(
            text: represent.displayName,
            font: represent.font(of: 12, weight: .semibold),
            textColor: self.isSelected ? UIColor.white : UIColor.black,
            letterSpacingPercentage: -0.43,
            alignment: .center
        )
    }
}
