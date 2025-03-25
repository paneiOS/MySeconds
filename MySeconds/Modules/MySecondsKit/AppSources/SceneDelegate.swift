//
//  SceneDelegate.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 3/25/25.
//

import UIKit

import ModernRIBs

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

        let vc = UIViewController()
        vc.view.backgroundColor = .blue

        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
}
