//
//  VideoRecordBuilder.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import UIKit

import ModernRIBs

import BaseRIBsKit
import SharedModels
import VideoDraftStorage
import VideoRecordingManager

public protocol VideoRecordDependency: Dependency {
    var videoDraftStorage: VideoDraftStorageDelegate { get }
    var videoRecordingManager: VideoRecordingManagerProtocol { get }
}

public final class VideoRecordComponent: Component<VideoRecordDependency> {
    public let clips: [CompositionClip]
    public let maxAlbumCount: Int

    public var videoDraftStorage: VideoDraftStorageDelegate {
        dependency.videoDraftStorage
    }

    public var videoRecordingManager: VideoRecordingManagerProtocol {
        dependency.videoRecordingManager
    }

    public init(dependency: VideoRecordDependency, clips: [CompositionClip], maxAlbumCount: Int) {
        self.clips = clips
        self.maxAlbumCount = maxAlbumCount

        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol VideoRecordBuildable: Buildable {
    func build(withListener listener: VideoRecordListener, clips: [CompositionClip], maxAlbumCount: Int) -> VideoRecordRouting
}

public final class VideoRecordBuilder: Builder<VideoRecordDependency>, VideoRecordBuildable {

    override public init(dependency: VideoRecordDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoRecordListener, clips: [CompositionClip], maxAlbumCount: Int) -> VideoRecordRouting {
        let component = VideoRecordComponent(dependency: dependency, clips: clips, maxAlbumCount: maxAlbumCount)
        let viewController = VideoRecordViewController(maxAlbumCount: maxAlbumCount)
        let interactor = VideoRecordInteractor(
            presenter: viewController,
            component: component
        )
        interactor.listener = listener
        return VideoRecordRouter(interactor: interactor, viewController: viewController)
    }
}
