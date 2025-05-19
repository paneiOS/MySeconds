//
//  SceneDelegate.swift
//  Login
//
//  Created by pane on 01/09/2025.
//

import UIKit

import ModernRIBs

import Login
import UtilsKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockLoginListener = .init()
    private var router: LoginRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let loginBuilder: LoginBuilder = .init(
            dependency: .init(
                dependency: EmptyComponent()
            )
        )
        let loginRouter = loginBuilder.build(withListener: self.mockListener)
        self.router = loginRouter
        self.window?.rootViewController = loginRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockLoginListener: LoginListener {
    func didLogin(with result: Login.LoginResult) {
        printDebug("MockLoginListener: didCompleteLogin, \(result)")
    }
}
