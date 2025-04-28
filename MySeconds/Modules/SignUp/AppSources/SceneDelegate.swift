//
//  SceneDelegate.swift
//  SignUp
//
//  Created by pane on 04/23/2025.
//

import UIKit

import ModernRIBs

import SignUp

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockSignUpListener = .init()
    private var router: SignUpRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let signUpBuilder = SignUpBuilder(
            dependency: .init(
                dependency: MockSignUpDependency()
            )
        )
        let signUpRouter = signUpBuilder.build(withListener: self.mockListener)
        self.router = signUpRouter

        self.window?.rootViewController = signUpRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockSignUpDependency: SignUpDependency {
    public var token: String {
        "mockTokenValue"
    }
}

final class MockSignUpListener: SignUpListener {}
