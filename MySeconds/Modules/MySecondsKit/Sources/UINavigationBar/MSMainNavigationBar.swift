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
        showLogo: Bool = false,
        title: String? = nil,
        hasBackButton: Bool = true,
        rightButtons: [MSNavigationBarButton]? = nil,
        rightButtonSpacing: CGFloat = 0
    ) {
        let naviItem = UINavigationItem(title: title ?? "")

        naviItem.leftBarButtonItem = self.makeLeftBarButtonItem(
            showLogo: showLogo,
            hasBackButton: hasBackButton
        )

        if let rightButtons {
            naviItem.rightBarButtonItems = self.setupRightButtonItems(
                buttons: rightButtons,
                spacing: rightButtonSpacing
            )
        }

        self.items = [naviItem]
    }

    // MARK: - Private Methods

    private func makeLeftBarButtonItem(showLogo: Bool, hasBackButton: Bool) -> UIBarButtonItem? {
        if hasBackButton {
            self.createBackButton()
        } else if showLogo {
            self.createLogoImage()
        } else {
            nil
        }
    }

    private func createLogoImage() -> UIBarButtonItem {
        let logoImageView = UIImageView(image: ResourceKitAsset.mysecondsLogo.image.withRenderingMode(.alwaysTemplate))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .neutral400
        logoImageView.frame = CGRect(x: 0, y: 0, width: 96, height: 32)

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
