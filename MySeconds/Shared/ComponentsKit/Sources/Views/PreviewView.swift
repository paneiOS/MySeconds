//
//  PreviewView.swift
//  ComponentsKit
//
//  Created by JeongHwan Lee on 7/30/25.
//

import UIKit

import SnapKit

import SharedModels
import UtilsKit

public final class PreviewView: UIView {
    public let titleLabel: UILabel = .init()
    public let descriptionLabel: UILabel = .init()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) { nil }

    private func setupUI() {
        self.addSubviews(self.titleLabel, self.descriptionLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(2)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    public func configure(with clip: VideoCoverClip) {
        self.titleLabel.attributedText = clip.title
        self.descriptionLabel.attributedText = clip.description
    }
}
