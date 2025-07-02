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
    var videoDraftStorage: VideoDraftStorage { get }
    var maxAlbumCount: Int { get }
}

public final class VideoRecordComponent: Component<VideoRecordDependency> {
    public let clips: [CompositionClip]

    public var videoDraftStorage: VideoDraftStorage {
        dependency.videoDraftStorage
    }

    public var maxAlbumCount: Int {
        dependency.maxAlbumCount
    }


    public init(dependency: VideoRecordDependency, clips: [CompositionClip]) {
        self.clips = clips
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol VideoRecordBuildable: Buildable {
    func build(withListener listener: VideoRecordListener, clips: [CompositionClip]) -> VideoRecordRouting
}

public final class VideoRecordBuilder: Builder<VideoRecordDependency>, VideoRecordBuildable {

    override public init(dependency: VideoRecordDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoRecordListener, clips: [CompositionClip]) -> VideoRecordRouting {
        let component = VideoRecordComponent(dependency: dependency, clips: clips)
        let viewController = VideoRecordViewController()
        let interactor = VideoRecordInteractor(presenter: viewController, component: component)
        let interactor = VideoRecordInteractor(
            presenter: viewController,
            component: component,
            recordingManager: recordingManager
        )
        interactor.listener = listener
        return VideoRecordRouter(interactor: interactor, viewController: viewController)
    }
}
