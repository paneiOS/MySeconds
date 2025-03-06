//
//  NavigationButton.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 2/26/25.
//

import UIKit

import ResourceKit
import SnapKit

public extension UIComponents.Buttons {
    final class NavigationButton: UIButton {
        public init(
            image: UIImage?,
            tintColor: UIColor = .neutral400,
            action: Selector,
            target: Any
        ) {
            super.init(frame: .zero)

            var config = UIButton.Configuration.plain()
            config.image = image?.withRenderingMode(.alwaysTemplate)
            config.imagePadding = 8
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24)

            self.configuration = config
            self.tintColor = tintColor
            self.addTarget(target, action: action, for: .touchUpInside)

            self.snp.makeConstraints {
                $0.height.width.equalTo(40)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
