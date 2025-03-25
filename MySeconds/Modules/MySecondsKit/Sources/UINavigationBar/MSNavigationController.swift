//
//  MSNavigationController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 3/25/25.
//

import UIKit

import SnapKit

public final class MSNavigationController: UINavigationController {

    private let msNaivagationBar = MainNavigationBar()

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
        self.setupMSNavigationBar()
    }

    private func setupMSNavigationBar() {
        view.addSubview(self.msNaivagationBar)
        self.msNaivagationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        self.msNaivagationBar.backButton.target = self
        self.msNaivagationBar.backButton.action = #selector(self.didTapBackButton)
    }

    public func pushViewController(
        _ viewController: UIViewController,
        title: String,
        rightButtons: [(UIImage, (() -> Void)?)]? = nil,
        animated: Bool
    ) {
        super.pushViewController(viewController, animated: animated)
        self.msNaivagationBar.configure(title: title, rightButtons: rightButtons)
    }

    @objc private func didTapBackButton() {
        self.popViewController(animated: true)
    }
}
