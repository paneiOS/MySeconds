//
//  MSMainNavigationBar.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 3/18/25.
//

import Combine
import UIKit

import ResourceKit

public enum NavigationLeftItemType {
    case logo(image: UIImage = ResourceKitAsset.mysecondsLogo.image,
              size: CGSize = CGSize(width: 96, height: 32))
    case backButton
    case text(text: String,
              fontSize: CGFloat,
              fontWeight: UIFont.Weight,
              fontColor: UIColor)
    case none
}

public final class MSNavigationBar: UINavigationBar {
    // MARK: - Properties

    public let backButtonTapped = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    public var backButtonHandler: (() -> Void)?

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
        appearance.shadowColor = .clear
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
        leftItemType: NavigationLeftItemType = .backButton,
        title: String? = nil,
        rightButtons: [MSNavigationBarButton]? = nil,
        rightButtonSpacing: CGFloat = 0
    ) {
        let naviItem = UINavigationItem(title: title ?? "")

        naviItem.leftBarButtonItem = self.makeLeftBarButtonItem(type: leftItemType)

        if let rightButtons {
            naviItem.rightBarButtonItems = self.setupRightButtonItems(
                buttons: rightButtons,
                spacing: rightButtonSpacing
            )
        }

        self.items = [naviItem]
    }

    // MARK: - Private Methods

    private func makeLeftBarButtonItem(type: NavigationLeftItemType) -> UIBarButtonItem? {
        switch type {
        case let .logo(image, size):
            self.createLogoImage(image, size)
        case .backButton:
            self.createBackButton()
        case let .text(text, fontSize, fontWeight, fontColor):
            self.createLeftTitle(
                text,
                fontSize: fontSize,
                fontWeight: fontWeight,
                fontColor: fontColor
            )
        case .none:
            nil
        }
    }

    private func createLeftTitle(
        _ text: String,
        fontSize: CGFloat,
        fontWeight: UIFont.Weight,
        fontColor: UIColor
    ) -> UIBarButtonItem {
        let label = UILabel()
        label.text = text
        label.textColor = fontColor
        label.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        return UIBarButtonItem(customView: label)
    }

    private func createLogoImage(_ image: UIImage, _ size: CGSize) -> UIBarButtonItem {
        let logoImageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .neutral400
        logoImageView.frame = CGRect(origin: .zero, size: size)
        return UIBarButtonItem(customView: logoImageView)
    }

    private func setupRightButtonItems(
        buttons: [MSNavigationBarButton],
        spacing: CGFloat
    ) -> [UIBarButtonItem]? {
        guard !buttons.isEmpty else { return nil }

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.distribution = .equalSpacing

        return [UIBarButtonItem(customView: stackView)]
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
                guard let self else { return }
                if let handler = self.backButtonHandler {
                    handler()
                } else {
                    self.findNavigationController()?.popViewController(animated: true)
                }
            }
            .store(in: &self.cancellables)

        return UIBarButtonItem(customView: button)
    }

    private func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let nav = next as? UINavigationController {
                return nav
            }
            responder = next
        }
        return nil
    }
}
