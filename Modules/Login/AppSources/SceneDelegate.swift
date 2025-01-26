//
//  SceneDelegate.swift
//  Login
//
//  Created by pane on 01/09/2025.
//

import UIKit

import Login
import ModernRIBs

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockLoginListener = .init()
    private var loginRouter: LoginRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let loginBuilder = LoginBuilder(dependency: EmptyComponent())
        let loginRouter = loginBuilder.build(withListener: self.mockListener)
        self.loginRouter = loginRouter
        self.window = window
        self.window?.rootViewController = loginRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}
