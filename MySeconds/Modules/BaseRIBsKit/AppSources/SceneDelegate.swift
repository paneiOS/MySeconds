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
    private var mockListener: MockBaseListener = .init()
    private var router: BaseRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let builder: BaseBuilder = .init(
            dependency: EmptyComponent()
        )
        let router = builder.build(withListener: self.mockListener)
        self.router = router
        self.window?.rootViewController = router.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockBaseDependency: Dependency {
    public var token: String {
        "mockTokenValue"
    }
}

final class MockBaseListener: BaseListener {}
