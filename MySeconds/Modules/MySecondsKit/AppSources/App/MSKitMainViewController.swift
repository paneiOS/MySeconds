//
//  MSKitMainViewController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import BaseRIBsKit
import MySecondsKit
import ResourceKit

final class MSKitMainViewController: BaseViewController, NavigationConfigurable {

    let label = UILabel()

    override func setupUI() {
        view.addSubview(self.label)
        view.backgroundColor = .white
        self.label.text = "Main View Controller"
        self.label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func navigationConfig() -> NavigationConfig {
        NavigationConfig(
            leftButtonType: .logo,
            rightButtonTypes: [
                .custom(image: ResourceKitAsset.chevronRight.image, tintColor: .neutral950, action: .push(MSKitSecondViewController(isPresent: false))),
                .custom(image: ResourceKitAsset.bookUser.image, tintColor: .neutral950, action: .present(MSKitSecondViewController(isPresent: true)))
            ]
        )
    }

    private func presentNext() {
        let secondVC = MSKitSecondViewController(isPresent: true)
        let nav = MSNavigationController(rootViewController: secondVC)
        self.present(nav, animated: true)
    }

    private func pushNext() {
        let secondVC = MSKitSecondViewController(isPresent: false)
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
}
