//
//  SceneDelegate.swift
//  BaseRIBsKit
//
//  Created by pane on 04/22/2025.
//

import UIKit

import BaseRIBsKit

import ModernRIBs

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var router: Routing?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let viewController = BaseViewController()
        let interactor = BaseInteractor(presenter: viewController)
        let router = BaseRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        self.router = router

        self.window = window
        self.window?.rootViewController = router.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}
