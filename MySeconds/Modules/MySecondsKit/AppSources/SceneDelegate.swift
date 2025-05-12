//
//  SceneDelegate.swift
//  MySecondsKit
//
//  Created by chungwussup on 05/09/2025.
//

import UIKit

import MySecondsKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let vc: UIViewController = MSKitMainViewController()
        let navigationController = UINavigationController(rootViewController: vc)

        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}
