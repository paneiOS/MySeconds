//
//  MSKitMainViewController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import MySecondsKit
import ResourceKit

final class MSKitMainViewController: MSBaseViewController {
    let label = UILabel()

    private let navigationBar = MSNavigationBar()

    private let imageButton = MSNavigationBarButton(
        image: ResourceKitAsset.image.image,
        imageSize: CGSize(width: 5, height: 5),
        tintColor: .blue
    )
    private let menuButton = MSNavigationBarButton(image: ResourceKitAsset.menu.image)

    override func setupUI() {
        self.view.addSubviews(self.label)
        self.label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.label.text = "Main View Controller"

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(self.navigationBar)

        self.navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        self.navigationBar.configure(
            showLogo: true,
            hasBackButton: false,
            rightButtons: [self.imageButton, self.menuButton]
        )
    }

    override func bind() {

        self.imageButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                let thirdVC = MSKitSecondViewController()
                thirdVC.isPresent = true
                let navigationController = UINavigationController(rootViewController: thirdVC)
                self.present(navigationController, animated: true)
            }
            .store(in: &self.cancellables)

        self.menuButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                let thirdVC = MSKitSecondViewController()
                thirdVC.isPresent = false
                self.navigationController?.pushViewController(thirdVC, animated: true)
            }
            .store(in: &self.cancellables)
    }
}
