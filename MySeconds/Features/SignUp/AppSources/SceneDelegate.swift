//
//  SceneDelegate.swift
//  SignUp
//
//  Created by pane on 04/23/2025.
//

import UIKit

import ModernRIBs

import SignUp
import UtilsKit

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

        let uid = "mockTokenValue"
        let mockComponent = MockSignUpDependency(uid: uid)
        let signUpBuilder = SignUpBuilder(dependency: mockComponent)
        let signUpRouter = signUpBuilder.build(withListener: self.mockListener, uid: uid)
        self.router = signUpRouter

        self.window?.rootViewController = signUpRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockSignUpDependency: SignUpDependency {
    let uid: String

    init(uid: String) {
        self.uid = uid
    }
}

final class MockSignUpListener: SignUpListener {
    func sendUserInfo(with userInfo: SignUp.AdditionalUserInfo) {
        printDebug("MockSignUpListener: sendUserInfo, \(userInfo)")
    }
}
