//
//  MSNavigationController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 3/25/25.
//

import UIKit

import SnapKit

public final class MSNavigationController: UINavigationController {

    private let msNavigationBar = MainNavigationBar()

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
        self.setupMSNavigationBar()
    }

    private func setupMSNavigationBar() {
        view.addSubview(self.msNavigationBar)
        self.msNavigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        self.msNavigationBar.backButton.target = self
        self.msNavigationBar.backButton.action = #selector(self.didTapBackButton)
    }
    
    public func msPushViewController(
        _ viewController: UIViewController,
        title: String,
        rightButtons: [(UIImage, (() -> Void)?)]? = nil,
        animated: Bool
    ) {
        super.pushViewController(viewController, animated: animated)
        self.msNavigationBar.configure(title: title, rightButtons: rightButtons)
    }

    @objc private func didTapBackButton() {
        self.popViewController(animated: true)
    }
}
