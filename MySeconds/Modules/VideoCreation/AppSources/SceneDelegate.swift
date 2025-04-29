//
//  SceneDelegate.swift
//  VideoCreation
//
//  Created by pane on 04/29/2025.
//

import UIKit

import ModernRIBs

import VideoCreation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockVideoCreationListener = .init()
    private var router: VideoCreationRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // TODO: - 모듈이름소문자로 수정 필요
        let VideoCreationBuilder = VideoCreationBuilder(
            dependency: .init(
                dependency: MockVideoCreationDependency()
            )
        )
        // TODO: - 모듈이름소문자로 수정 필요
        let VideoCreationRouter = VideoCreationBuilder.build(withListener: self.mockListener)
        self.router = VideoCreationRouter

        self.window?.rootViewController = VideoCreationRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockVideoCreationDependency: VideoCreationDependency {
    public var token: String {
        "mockTokenValue"
    }
}

final class MockVideoCreationListener: VideoCreationListener {}
