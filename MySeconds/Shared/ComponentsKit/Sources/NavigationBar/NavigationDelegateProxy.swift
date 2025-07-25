//
//  NavigationDelegateProxy.swift
//  MySeconds
//
//  Created by 이정환 on 7/11/25.
//

import Combine
import UIKit

public final class NavigationDelegateProxy: NSObject, UINavigationControllerDelegate {
    private let poppedViewControllerSubject = PassthroughSubject<UIViewController, Never>()
    public var popedViewControllerPublisher: AnyPublisher<UIViewController, Never> {
        self.poppedViewControllerSubject.eraseToAnyPublisher()
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let option = viewController.navigationOption else { return }
        switch option {
        case .showsNavigationBar:
            navigationController.setNavigationBarHidden(false, animated: animated)
        case .hidesNavigationBar:
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(fromViewController) else {
            return
        }
        self.poppedViewControllerSubject.send(fromViewController)
    }
}
