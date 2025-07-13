//
//  SceneDelegate.swift
//  ComponentsKit
//
//  Created by chungwussup on 05/09/2025.
//

import UIKit

import ComponentsKit

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

        let mainVC: UIViewController = MSKitMainViewController()
        let navigationController = MSNavigationController(rootViewController: mainVC)

        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}
