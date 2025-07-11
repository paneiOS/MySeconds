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
    private let clips: [CompositionClip]
    public let recordingOptions: RecordingOptions

    public var videoDraftStorage: VideoDraftStorageDelegate {
        dependency.videoDraftStorage
    }

    public var videoRecordingManager: VideoRecordingManagerProtocol {
        dependency.videoRecordingManager
    }

    public init(dependency: VideoRecordDependency, clips: [CompositionClip], recordingOptions: RecordingOptions) {
        self.clips = clips
        self.recordingOptions = recordingOptions

        super.init(dependency: dependency)
    }
}

extension VideoRecordComponent: VideoRecordDependency {}

// MARK: - Builder

public protocol VideoRecordBuildable: Buildable {
    func build(withListener listener: VideoRecordListener, clips: [CompositionClip], recordingOptions: RecordingOptions) -> VideoRecordRouting
}

public final class VideoRecordBuilder: Builder<VideoRecordDependency>, VideoRecordBuildable {

    override public init(dependency: VideoRecordDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoRecordListener, clips: [CompositionClip], recordingOptions: RecordingOptions) -> VideoRecordRouting {
        let component = VideoRecordComponent(dependency: dependency, clips: clips, recordingOptions: recordingOptions)
        if clips.isEmpty {
            let drafts: [CompositionClip] = [
                .cover(.init(title: nil, description: nil, type: .intro)),
                .cover(.init(title: nil, description: nil, type: .outro))
            ]
            try? component.videoDraftStorage.updateBackup(drafts)
        }
        let viewController = VideoRecordViewController()
        let interactor = VideoRecordInteractor(
            presenter: viewController,
            component: component
        )
        interactor.listener = listener
        return VideoRecordRouter(interactor: interactor, viewController: viewController)
    }
}
