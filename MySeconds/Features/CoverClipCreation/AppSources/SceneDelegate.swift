//
//  SceneDelegate.swift
//  CoverClipCreation
//
//  Created by pane on 05/15/2025.
//

import UIKit

import ModernRIBs

import CoverClipCreation
import SharedModels
import UtilsKit

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

        let depndency: MockCoverClipCreationDependency = .init()
        let coverClipCreationBuilder = CoverClipCreationBuilder(dependency: depndency)
        let coverClipCreationRouter = coverClipCreationBuilder.build(withListener: self.mockListener, videoCoverClip: depndency.coverClip)
        self.router = coverClipCreationRouter

        self.window?.rootViewController = coverClipCreationRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockCoverClipCreationListener: CoverClipCreationListener {
    func closeCoverClipCreation() {
        printDebug("closeCoverClipCreation")
    }
}

final class MockCoverClipCreationDependency: CoverClipCreationDependency {
    var coverClip: VideoCoverClip {
        .init(title: nil, description: nil, type: .intro)
    }
}
