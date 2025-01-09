//
//  SceneDelegate.swift
//  Login
//
//  Created by pane on 01/09/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .white

        self.window = window
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()

        print("SceneDelegate: Scene will connect to session")
    }

    func sceneDidDisconnect(_: UIScene) {
        print("SceneDelegate: Scene did disconnect")
    }

    func sceneDidBecomeActive(_: UIScene) {
        print("SceneDelegate: Scene did become active")
    }

    func sceneWillResignActive(_: UIScene) {
        print("SceneDelegate: Scene will resign active")
    }

    func sceneWillEnterForeground(_: UIScene) {
        print("SceneDelegate: Scene will enter foreground")
    }

    func sceneDidEnterBackground(_: UIScene) {
        print("SceneDelegate: Scene did enter background")
    }
}
