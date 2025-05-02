//
//  SceneDelegate.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import UIKit

import ModernRIBs

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var launchRouter: LaunchRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let appComponent = AppComponent()
        let launchRouter = RootBuilder(dependency: appComponent).build()
        self.launchRouter = launchRouter
        launchRouter.launch(from: window)

        self.window?.makeKeyAndVisible()
    }
}
