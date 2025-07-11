//
//  SceneDelegate.swift
//  VideoRecord
//
//  Created by chungwussup on 05/19/2025.
//

import AVFoundation
import UIKit

import ModernRIBs

import MySecondsKit
import ResourceKit
import SharedModels
import VideoDraftStorage
import VideoRecord
import VideoRecordingManager

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

        let dependency: MockVideoRecordDependency = .init()
        let videoRecordBuilder = VideoRecordBuilder(dependency: dependency)

        let recordingOptions: RecordingOptions = .init(
            coverClipsCount: 2,
            maxVideoClipsCount: 15,
            recordDurations: [1.0, 2.0, 3.0],
            ratioTypes: [.oneToOne, .threeToFour]
        )
        let videoRecordRouter = videoRecordBuilder.build(
            withListener: self.mockListener,
            clips: [],
            recordingOptions: recordingOptions
        )
        self.router = videoRecordRouter
        videoRecordRouter.load()
        videoRecordRouter.interactable.activate()
        let root = videoRecordRouter.viewControllable.uiviewController
        let naviController = MSNavigationController(rootViewController: root)

        self.window?.rootViewController = naviController
        self.window?.makeKeyAndVisible()
    }
}

final class MockVideoRecordDependency: VideoRecordDependency {
    var videoDraftStorage: VideoDraftStorageDelegate = {
        do {
            return try VideoDraftStorage()
        } catch {
            fatalError("초기화실패 mock error: \(error)")
        }
    }()

    var videoRecordingManager: VideoRecordingManagerProtocol {
        VideoRecordingManager()
    }
}

final class MockVideoRecordListener: VideoRecordListener {
    func showVideoCreation(clips: [CompositionClip]) {
        print("clips", clips.count)
    }
}
