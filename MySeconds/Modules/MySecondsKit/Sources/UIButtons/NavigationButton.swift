//
//  NavigationButton.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 2/26/25.
//

import ResourceKit
import UIKit

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
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: 40),
                self.heightAnchor.constraint(equalToConstant: 40)
            ])
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
