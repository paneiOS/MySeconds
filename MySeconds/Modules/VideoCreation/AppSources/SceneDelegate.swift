//
//  SceneDelegate.swift
//  VideoCreation
//
//  Created by pane on 04/29/2025.
//

import AVFoundation
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
    public var clips: [CompositionClip] {
        [
            .cover(self.makeIntroClip()),
//            .video(self.makeSampleClip(named: "sample", ext: "mp4"))
            .cover(self.makeOutroClip())
        ]
    }
}

final class MockVideoCreationListener: VideoCreationListener {}

extension MockVideoCreationDependency {
    func makeSampleClip(named name: String, ext: String) -> VideoClip {
        #if SWIFT_PACKAGE
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        guard let sourceURL = bundle.url(forResource: name, withExtension: ext) else {
            fatalError("⚠️ \(name).\(ext) not found in bundle")
        }
        let fileManager = FileManager.default
        let appSupport = fileManager
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        let clipsFolder = appSupport
            .appendingPathComponent("VideoClips", isDirectory: true)
        if !fileManager.fileExists(atPath: clipsFolder.path) {
            try? fileManager.createDirectory(
                at: clipsFolder,
                withIntermediateDirectories: true
            )
        }

        let filename = sourceURL.lastPathComponent
        let destURL = clipsFolder.appendingPathComponent(filename)
        if !fileManager.fileExists(atPath: destURL.path) {
            do {
                try fileManager.copyItem(at: sourceURL, to: destURL)
            } catch {
                fatalError("⚠️ sample copy failed: \(error)")
            }
        }
        let asset = AVURLAsset(url: destURL)

        // MARK: - 경고창을 무시하고 사용하는 이유는 Mock데이터이며 async방식으로 처리하기엔 MockData치고 부담스러움

        let durationInSeconds = asset.duration.seconds
        return VideoClip(fileName: filename, duration: durationInSeconds)
    }

    func makeIntroClip() -> CoverClip {
        .init(title: "인트로", date: Date(), type: .intro)
    }

    func makeOutroClip() -> CoverClip {
        .init(title: "인트로", date: Date(), type: .outro)
    }
}
