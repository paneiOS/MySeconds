//
//  SceneDelegate.swift
//  BGMSelect
//
//  Created by pane on 05/28/2025.
//

import AVFoundation
import UIKit

import ModernRIBs

import BGMSelect
import ResourceKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockBGMSelectListener = .init()
    private var router: BGMSelectRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession 설정 실패:", error)
        }

        let bundle = ResourceKitResources.bundle
        guard let bgmsDir = bundle.url(forResource: "BGMs", withExtension: nil) else { return }
        let builder = BGMSelectBuilder(dependency: MockBGMSelectDependency(bgmDirectoryURL: bgmsDir))
        let router = builder.build(withListener: self.mockListener)
        self.router = router

        self.window?.rootViewController = router.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

final class MockBGMSelectDependency: BGMSelectDependency {
    var bgmDirectoryURL: URL

    init(bgmDirectoryURL: URL) {
        self.bgmDirectoryURL = bgmDirectoryURL
    }
}

final class MockBGMSelectListener: BGMSelectListener {}
