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

        let videoCreationBuilder = VideoCreationBuilder(
            dependency: .init(
                dependency: MockVideoCreationDependency()
            )
        )
        let videoCreationRouter = videoCreationBuilder.build(withListener: self.mockListener)
        self.router = videoCreationRouter

        self.window?.rootViewController = videoCreationRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockVideoCreationDependency: VideoCreationDependency {
    public var segments: [VideoCreation.VideoSegment] {
        []
    }
}

final class MockVideoCreationListener: VideoCreationListener {}
