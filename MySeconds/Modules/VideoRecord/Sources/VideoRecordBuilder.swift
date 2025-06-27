//
//  VideoRecordBuilder.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import UIKit

import ModernRIBs

import BaseRIBsKit
import VideoDraftStorage
import VideoRecordingManager

public protocol VideoRecordDependency: Dependency {
    var videoDraftStorage: VideoDraftStorage { get }
}

public final class VideoRecordComponent: Component<VideoRecordDependency> {
    public var videoDraftStorage: VideoDraftStorage {
        dependency.videoDraftStorage
    }
}

extension VideoRecordComponent: VideoRecordDependency {}

// MARK: - Builder

public protocol VideoRecordBuildable: Buildable {
    func build(withListener listener: VideoRecordListener) -> VideoRecordRouting
}

public final class VideoRecordBuilder: Builder<VideoRecordComponent>, VideoRecordBuildable {

    override public init(dependency: VideoRecordComponent) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoRecordListener) -> VideoRecordRouting {
        let component = VideoRecordComponent(dependency: dependency)
        let recordingManager = VideoRecordingManager()
        let viewController = VideoRecordViewController(recordingManager: recordingManager)
        let interactor = VideoRecordInteractor(
            presenter: viewController,
            component: component,
            recordingManager: recordingManager
        )
        interactor.listener = listener
        return VideoRecordRouter(interactor: interactor, viewController: viewController)
    }
}
