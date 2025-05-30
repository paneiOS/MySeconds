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

final class MockVideoRecordDependency: VideoRecordDependency {
    var initialAlbumThumbnail: UIImage? {

        guard let url = ResourceKitResources.bundle.url(forResource: "sample01", withExtension: "mp4") else {
            print("⚠️ sample01.mp4 를 번들에서 찾을 수 없습니다.")
            return nil
        }
        return makeThumbnail(from: url)
    }

    var initialAlbumCount: Int = 10
}

final class MockVideoRecordListener: VideoRecordListener {}

extension MockVideoRecordDependency {
    func makeThumbnail(from videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600) // 1초 지점

        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("썸네일 생성 실패:", error)
            return nil
        }
    }
}
