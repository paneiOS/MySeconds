//
//  SceneDelegate.swift
//  VideoCreation
//
//  Created by pane on 04/29/2025.
//

import AVFoundation
import UIKit

import ModernRIBs

import ResourceKit
import SharedModels
import VideoCreation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var mockListener: MockVideoCreationListener = .init()
    private var router: VideoCreationRouting?

    var clips: [CompositionClip] {
        [
            .cover(self.makeIntroClip()),
            .video(self.makeSampleClip(named: "sample", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample01", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample02", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample03", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample04", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample05", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample06", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample07", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample08", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample09", ext: "mp4")),
            .video(self.makeSampleClip(named: "sample10", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample11", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample12", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample13", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample14", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample15", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample16", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample17", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample18", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample19", ext: "mp4")),
            //            .video(self.makeSampleClip(named: "sample20", ext: "mp4")),
            .cover(self.makeOutroClip())
        ]
    }

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let mockComponent = MockVideoCreationComponent(clips: self.clips)
        let videoCreationBuilder = VideoCreationBuilder(dependency: mockComponent)
        let videoCreationRouter = videoCreationBuilder.build(withListener: self.mockListener, clips: self.clips)
        self.router = videoCreationRouter

        self.window?.rootViewController = videoCreationRouter.viewControllable.uiviewController
        self.window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    func makeSampleClip(named name: String, ext: String) -> VideoClip {
        let bundle = ResourceKitResources.bundle

        guard let sourceURL = bundle.url(forResource: name, withExtension: ext) else {
            fatalError("⚠️ \(name).\(ext) not found in ResourceKit bundle")
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

        // TODO: - 썸네일 넣어야함...
        return VideoClip(duration: durationInSeconds, thumbnail: nil)
    }

    func makeIntroClip() -> VideoCoverClip {
        .init(
            title: .makeAttributedString(
                text: "샘플 인트로",
                font: .systemFont(ofSize: 12.0, weight: .semibold),
                textColor: .white,
                letterSpacingPercentage: -0.43,
                alignment: .center
            ),
            description: .makeAttributedString(
                text: Date().dateToString,
                font: .systemFont(ofSize: 10.0, weight: .semibold),
                textColor: .white,
                letterSpacingPercentage: -0.43,
                alignment: .center
            ),
            type: .intro
        )
    }

    func makeOutroClip() -> VideoCoverClip {
        .init(
            title: .makeAttributedString(
                text: "샘플 아웃트로",
                font: .systemFont(ofSize: 12.0, weight: .semibold),
                textColor: .white,
                letterSpacingPercentage: -0.43,
                alignment: .center
            ),
            description: .makeAttributedString(
                text: Date().dateToString,
                font: .systemFont(ofSize: 10.0, weight: .semibold),
                textColor: .white,
                letterSpacingPercentage: -0.43,
                alignment: .center
            ),
            type: .outro
        )
    }
}

final class MockVideoCreationComponent: VideoCreationDependency {
    let clips: [CompositionClip]

    init(clips: [CompositionClip]) {
        self.clips = clips
    }
}

final class MockVideoCreationListener: VideoCreationListener {
    func didSelectCoverClip(clip: SharedModels.VideoCoverClip) {
        print("didSelectCoverClip")
    }

    func bgmSelectButtonTapped() {
        print("bgmSelectButtonTapped")
    }

    func videoCreationDidFinish() {
        print("videoCreationDidFinish 호출됨")
    }

    func videoCreationDidSelectCoverClip(_ clip: VideoCoverClip) {
        print("videoCreationDidSelectCoverClip: \(clip)")
    }
}
