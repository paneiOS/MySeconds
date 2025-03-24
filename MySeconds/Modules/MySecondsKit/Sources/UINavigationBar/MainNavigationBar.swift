//
//  MainNavigationBar.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 3/18/25.
//

import UIKit

import ResourceKit

public protocol MainNavigationBarDelegate: AnyObject {
    func didTapBackButton()
}

public final class MainNavigationBar: UINavigationBar {

    // MARK: - Properties

    public weak var navigationDelegate: MainNavigationBarDelegate?

    private lazy var backButton: UIButton = {
        let action = UIAction(image: ResourceKitAsset.chevronLeft.image
            .withRenderingMode(.alwaysTemplate)) { _ in
                self.navigationDelegate?.didTapBackButton()
            }
        let button = UIButton(type: .custom, primaryAction: action)
        button.tintColor = .neutral800
        return button
    }()

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNavigationBar()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupNavigationBar()
    }

    // MARK: - Setup Methods

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.neutral800,
            .font: UIFont.systemFont(ofSize: 16)
        ]
        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
        self.compactAppearance = appearance
    }

    // MARK: - Public Methods

    public func configure(
        title: String,
        rightButtons: [(UIImage, (() -> Void)?)]? = nil
    ) {
        let naviItem = UINavigationItem(title: title)

        naviItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        naviItem.rightBarButtonItems = self.setupRightButtonItems(buttons: rightButtons)

        self.items = [naviItem]
    }

    // MARK: - Private Methods

    private func setupRightButtonItems(
        buttons: [(UIImage, (() -> Void)?)]?
    ) -> [UIBarButtonItem]? {
        guard let buttons, !buttons.isEmpty else { return nil }

        return buttons.map { image, action in
            let button = self.createButton(image: image, action: action)
            return UIBarButtonItem(customView: button)
        }
    }

    private func createButton(image: UIImage, action: (() -> Void)?) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black

        if let action {
            button.addAction(UIAction { _ in
                action()
            }, for: .touchUpInside)
        }
        
        return button
    }
}
