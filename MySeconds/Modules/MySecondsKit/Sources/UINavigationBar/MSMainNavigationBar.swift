//
//  MSMainNavigationBar.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 3/18/25.
//

import Combine
import UIKit

import ResourceKit

public final class MSNavigationBar: UINavigationBar {
    public typealias MSNavigationRightButton = (image: UIImage, tapPublisher: PassthroughSubject<Void, Never>)

    // MARK: - Properties

    public let backButtonTapped = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNavigationBar()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        isMain: Bool = false,
        title: String? = nil,
        hasBackButton: Bool = true,
        rightButtons: [MSNavigationRightButton]? = nil
    ) {
        let naviItem = UINavigationItem(title: title ?? "")

        naviItem.leftBarButtonItem = self.makeLeftBarButtonItem(
            isMain: isMain,
            hasBackButton: hasBackButton
        )

        naviItem.rightBarButtonItems = self.setupRightButtonItems(buttons: rightButtons)

        self.items = [naviItem]
    }

    // MARK: - Private Methods

    private func makeLeftBarButtonItem(isMain: Bool, hasBackButton: Bool) -> UIBarButtonItem? {
        if hasBackButton {
            self.createBackButton()
        } else if isMain {
            self.createLogoImage()
        } else {
            nil
        }
    }

    private func createLogoImage() -> UIBarButtonItem {
        let logoImageView = UIImageView(image: ResourceKitAsset.mysecondsLogo.image.withRenderingMode(.alwaysTemplate))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .neutral400

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 95.8, height: 32))
        logoImageView.frame = containerView.bounds
        containerView.addSubview(logoImageView)

        return UIBarButtonItem(customView: containerView)
    }

    private func setupRightButtonItems(
        buttons: [MSNavigationRightButton]?
    ) -> [UIBarButtonItem]? {
        guard let buttons, !buttons.isEmpty else { return nil }

        return buttons.map { image, publisher in
            let button = UIButton(type: .custom)
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = .black
            button.publisher(for: .touchUpInside)
                .sink { _ in
                    publisher.send()
                }
                .store(in: &self.cancellables)

            return UIBarButtonItem(customView: button)
        }
    }

    private func createBackButton() -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(
            ResourceKitAsset.chevronLeft.image.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .neutral800

        button.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.backButtonTapped.send()
            }
            .store(in: &self.cancellables)

        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }
}
