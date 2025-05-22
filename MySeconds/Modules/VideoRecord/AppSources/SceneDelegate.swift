//
//  SceneDelegate.swift
//  VideoRecord
//
//  Created by chungwussup on 05/19/2025.
//

import UIKit

import ModernRIBs

import MySecondsKit
import VideoRecord

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockVideoRecordListener = .init()
    private var router: VideoRecordRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let videoRecordBuilder = VideoRecordBuilder(
            dependency: .init(
                dependency: MockVideoRecordDependency()
            )
        )

        let videoRecordRouter = videoRecordBuilder.build(withListener: self.mockListener)
        self.router = videoRecordRouter

        let root = videoRecordRouter.viewControllable.uiviewController
        let naviController = MSNavigationController(rootViewController: root)

        self.window?.rootViewController = naviController
        self.window?.makeKeyAndVisible()
    }
}

final class MockVideoRecordDependency: VideoRecordDependency {}

final class MockVideoRecordListener: VideoRecordListener {}
