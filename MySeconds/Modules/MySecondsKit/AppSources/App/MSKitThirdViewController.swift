//
//  MSKitThirdViewController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import MySecondsKit
import ResourceKit

class MSKitThirdViewController: MSBaseViewController {
    let label = UILabel()

    var isPresent = false

    private let navigationBar = MSNavigationBar()

    private let closeButton = MSNavigationBarButton(image: ResourceKitAsset.close.image)

    override func setupUI() {
        self.view.addSubviews(self.label)
        self.label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.label.text = self.isPresent ? "Present View Controller" : "Push View Controller"

        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        self.view.addSubview(self.navigationBar)

        self.navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        self.navigationBar.configure(
            leftItemType: self.isPresent ? .text(
                text: "왼쪽 텍스트",
                fontSize: 25,
                fontWeight: .bold,
                fontColor: .black
            ) : .backButton,
            title: "Third View",
            rightButtons: self.isPresent ? [
                self.closeButton
            ] : []
        )
    }

    override func bind() {
        self.closeButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
    }
}
