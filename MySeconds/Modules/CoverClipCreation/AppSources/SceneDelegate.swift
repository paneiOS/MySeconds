//
//  SceneDelegate.swift
//  CoverClipCreation
//
//  Created by pane on 05/15/2025.
//

import UIKit

import ModernRIBs

import CoverClipCreation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockCoverClipCreationListener = .init()
    private var router: CoverClipCreationRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let coverClipCreationBuilder = CoverClipCreationBuilder(
            dependency: .init(
                dependency: MockCoverClipCreationDependency()
            )
        )
        let coverClipCreationRouter = coverClipCreationBuilder.build(withListener: self.mockListener)
        self.router = coverClipCreationRouter

        self.window?.rootViewController = coverClipCreationRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockCoverClipCreationListener: CoverClipCreationListener {}

final class MockCoverClipCreationDependency: CoverClipCreationDependency {
    var coverClip: CoverClip {
        .init(position: .intro, title: "", description: "")
    }
}
