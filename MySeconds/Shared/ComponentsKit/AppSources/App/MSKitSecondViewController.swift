//
//  MSKitSecondViewController.swift
//  ComponentsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import BaseRIBsKit
import ComponentsKit
import ResourceKit

final class MSKitSecondViewController: BaseViewController, NavigationConfigurable {
    private let isPresent: Bool
    let label = UILabel()

    init(isPresent: Bool) {
        self.isPresent = isPresent
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        view.addSubview(self.label)
        self.label.text = self.isPresent ? "Present View Controller" : "Push View Controller"
        self.label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        view.backgroundColor = .white
    }

    func navigationConfig() -> NavigationConfig {
        NavigationConfig(
            title: "Seconds View",
            leftButtonType: nil,
            rightButtonTypes: [
                .custom(
                    image: ResourceKitAsset.ban.image,
                    tintColor: .neutral950,
                    action: .present(MSKitThirdViewController(isPresent: true))
                ),
                .custom(
                    image: ResourceKitAsset.archive.image,
                    tintColor: .neutral950,
                    action: .push(MSKitThirdViewController(isPresent: false))
                )
            ]
        )
    }
}
