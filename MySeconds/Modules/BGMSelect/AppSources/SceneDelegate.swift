//
//  SceneDelegate.swift
//  BGMSelect
//
//  Created by pane on 05/28/2025.
//

import UIKit

import ModernRIBs

import BGMSelect

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockBGMSelectListener = .init()
    private var router: BGMSelectRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let builder = BGMSelectBuilder(dependency: MockBGMSelectDependency())
        let router = builder.build(withListener: self.mockListener)
        self.router = router

        self.window?.rootViewController = router.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockBGMSelectDependency: BGMSelectDependency {}

final class MockBGMSelectListener: BGMSelectListener {}
