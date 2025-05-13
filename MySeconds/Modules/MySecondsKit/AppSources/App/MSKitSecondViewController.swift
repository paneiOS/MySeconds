//
//  MSKitSecondViewController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import MySecondsKit
import ResourceKit

class MSKitSecondViewController: MSBaseViewController {
    let label = UILabel()

    var isPresent = false

    private let navigationBar = MSNavigationBar()

    private let banButton = MSNavigationBarButton(image: ResourceKitAsset.ban.image)
    private let bookUserButton = MSNavigationBarButton(image: ResourceKitAsset.bookUser.image)
    private let closeButton = MSNavigationBarButton(image: ResourceKitAsset.close.image)

    override func setupUI() {
        self.view.addSubviews(self.label)
        self.label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        self.label.text = self.isPresent ? "Present View Controller" : "Push View Controller"

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(self.navigationBar)

        self.navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        self.navigationBar.configure(
            leftItemType: self.isPresent ? .none : .backButton,
            title: "Second View",
            rightButtons: [self.banButton, self.bookUserButton]
                + (self.isPresent ? [self.closeButton] : [])
        )
    }

    override func bind() {
        self.banButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let thirdViewController = MSKitThirdViewController()
                thirdViewController.isPresent = false
                self.navigationController?.pushViewController(thirdViewController, animated: true)
            }
            .store(in: &self.cancellables)

        self.bookUserButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let thirdViewController = MSKitThirdViewController()
                thirdViewController.isPresent = true
                self.navigationController?.present(thirdViewController, animated: true)
            }
            .store(in: &self.cancellables)

        self.closeButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
    }
}
