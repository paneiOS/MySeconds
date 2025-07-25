//
//  SceneDelegate.swift
//  VideoRecord
//
//  Created by chungwussup on 05/19/2025.
//

import AVFoundation
import UIKit

import ModernRIBs

import ComponentsKit
import ResourceKit
import SharedModels
import VideoDraftStorage
import VideoRecord
import VideoRecordingManager

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockVideoRecordListener = .init()
    private var rootNavigationController: UINavigationController?
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
        let naviController = UINavigationController(rootViewController: root)
        naviController.navigationBar.isHidden = true
        naviController.delegate = self
        self.rootNavigationController = naviController
        self.mockListener.rootNavigationController = naviController
        self.window?.rootViewController = naviController
        self.window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let shouldHideBar = viewController is CustomHeaderNavigation
        navigationController.setNavigationBarHidden(shouldHideBar, animated: animated)
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
    weak var rootNavigationController: UINavigationController?

    func showVideoCreation(clips: [CompositionClip]) {
        let viewController = UIViewController()
        viewController.title = "비디오 만들기"
        viewController.view.backgroundColor = .red
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    func showAlbumRIB() {
        let viewController = UIViewController()
        viewController.title = "앨범 화면"
        viewController.view.backgroundColor = .green
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

    func showMenuRIB() {
        let viewController = UIViewController()
        viewController.title = "메뉴 화면"
        viewController.view.backgroundColor = .blue
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }
}
