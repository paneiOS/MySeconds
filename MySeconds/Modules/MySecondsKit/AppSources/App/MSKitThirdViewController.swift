//
//  MSKitThirdViewController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import BaseRIBsKit
import MySecondsKit
import ResourceKit

final class MSKitThirdViewController: BaseViewController, NavigationConfigurable {

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
            title: "Third View",
            leftButtonType: self.isPresent ? .text(
                text: "왼쪽 텍스트",
                fontSize: 25,
                fontWeight: .bold,
                fontColor: .neutral950
            ) : nil,
            rightButtonTypes: self.isPresent ? [
                .custom(image: ResourceKitAsset.close.image, tintColor: .neutral950, action: .dismiss())
            ] : []
        )
    }
}
