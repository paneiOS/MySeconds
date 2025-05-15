//
//  MSNavigationController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/14/25.
//

import Combine
import UIKit

import ResourceKit

public protocol NavigationConfigurable {
    func navigationConfig() -> NavigationConfig
}

public enum NavigationAction {
    case push(UIViewController)
    case present(UIViewController, embedInNavigation: Bool = true)
    case dismiss
    case pop
    case popToRoot
    case custom(() -> Void)
}

public enum NavigationButtonType {
    case logo
    case text(
        text: String,
        fontSize: CGFloat,
        fontWeight: UIFont.Weight,
        fontColor: UIColor
    )
    case custom(
        image: UIImage,
        imageSize: CGSize = .init(width: 24, height: 24),
        tintColor: UIColor = .neutral950,
        action: NavigationAction
    )
}

public struct NavigationConfig {
    public var title: String?
    public var leftButtonType: NavigationButtonType?
    public var rightButtonTypes: [NavigationButtonType]?
    public var rightButtonSpacing: CGFloat = 0

    public init(
        title: String? = nil,
        leftButtonType: NavigationButtonType? = nil,
        rightButtonTypes: [NavigationButtonType]? = nil,
        rightButtonSpacing: CGFloat = 0
    ) {
        self.title = title
        self.leftButtonType = leftButtonType
        self.rightButtonTypes = rightButtonTypes
        self.rightButtonSpacing = rightButtonSpacing
    }
}

public final class MSNavigationController: UINavigationController, UINavigationControllerDelegate {
    private var cancellables = Set<AnyCancellable>()

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.configureAppearance()
    }

    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.neutral800,
            .font: UIFont.systemFont(ofSize: 16)
        ]
        appearance.setBackIndicatorImage(
            ResourceKitAsset.chevronLeft.image,
            transitionMaskImage: ResourceKitAsset.chevronLeft.image
        )

        appearance.backButtonAppearance.normal.backgroundImage?.withTintColor(.black)
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear, .font: UIFont.systemFont(ofSize: 0)]

        self.navigationBar.tintColor = .black
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }

    public func navigationController(
        _: UINavigationController,
        willShow viewController: UIViewController,
        animated _: Bool
    ) {
        guard let configurable = viewController as? NavigationConfigurable else { return }

        let config = configurable.navigationConfig()
        viewController.navigationItem.title = config.title

        if let leftType = config.leftButtonType {
            viewController.navigationItem.leftBarButtonItem = self.makeBarButton(from: leftType)
        } else {
            viewController.navigationItem.leftBarButtonItem = nil
        }

        if let rightTypes = config.rightButtonTypes {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = config.rightButtonSpacing
            stackView.alignment = .center
            stackView.distribution = .fill

            for type in rightTypes {
                let button = self.makeBarButton(from: type).customView
                if let button {
                    stackView.addArrangedSubview(button)
                }
            }
            viewController.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: stackView)]
        } else {
            viewController.navigationItem.rightBarButtonItems = nil
        }
    }

    private func makeBarButton(from type: NavigationButtonType) -> UIBarButtonItem {
        switch type {
        case .logo:
            let logoImageView = UIImageView(image: ResourceKitAsset.mysecondsLogo.image.withRenderingMode(.alwaysTemplate))
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.tintColor = .neutral400
            logoImageView.frame = CGRect(origin: .zero, size: CGSize(width: 96, height: 32))

            return UIBarButtonItem(customView: logoImageView)
        case let .custom(image, imageSize, tintColor, action):
            let button = MSNavigationBarButton(
                image: image,
                imageSize: imageSize,
                tintColor: tintColor
            )

            button.publisher(for: .touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    guard let self else { return }
                    self.handleAction(action)
                })
                .store(in: &self.cancellables)

            return UIBarButtonItem(customView: button)
        case let .text(text, fontSize, fontWeight, fontColor):
            let label = UILabel()
            label.text = text
            label.textColor = fontColor
            label.font = .systemFont(ofSize: fontSize, weight: fontWeight)
            return UIBarButtonItem(customView: label)
        }
    }

    private func handleAction(_ action: NavigationAction) {
        switch action {
        case let .push(viewController):
            self.pushViewController(viewController, animated: true)
        case let .present(viewController, embedInNavigation):
            let targetVC: UIViewController = if embedInNavigation {
                MSNavigationController(rootViewController: viewController)
            } else {
                viewController
            }
            self.present(targetVC, animated: true)
        case .dismiss:
            self.dismiss(animated: true)
        case .pop:
            self.popViewController(animated: true)
        case .popToRoot:
            self.popToRootViewController(animated: true)
        case let .custom(customAction):
            customAction()
        }
    }
}
