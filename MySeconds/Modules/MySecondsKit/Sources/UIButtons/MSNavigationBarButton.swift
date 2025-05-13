//
//  MSNavigationBarButton.swift
//  MySecondsKitMoudleApp
//
//  Created by Chung Wussup on 5/13/25.
//

import Combine
import UIKit

import ResourceKit

public final class MSNavigationBarButton: UIButton {
    public let tapPublisher = PassthroughSubject<Void, Never>()

    public init(
        image: UIImage,
        imageSize: CGSize = CGSize(width: 24, height: 24),
        tintColor: UIColor = .neutral400
    ) {
        super.init(frame: .zero)
        self.setupUI(
            image: image,
            imageSize: imageSize,
            tintColor: tintColor
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(
        image: UIImage,
        imageSize: CGSize,
        tintColor: UIColor
    ) {
        self.tintColor = tintColor

        self.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }

        var config = UIButton.Configuration.plain()
        config.image = image.resized(to: imageSize).withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = tintColor
        config.contentInsets = .zero

        self.configuration = config

        self.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.tapPublisher.send()
        }, for: .touchUpInside)
    }
}
