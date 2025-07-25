//
//  VideoCreationBuilder.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import CoverClipCreation
import SharedModels
import VideoDraftStorage

public protocol VideoCreationDependency: Dependency {
    var videoDraftStorage: VideoDraftStorageDelegate { get }
}

public final class VideoCreationComponent: Component<VideoCreationDependency> {
    public let clips: [CompositionClip]

    public var videoDraftStorage: VideoDraftStorageDelegate {
        dependency.videoDraftStorage
    }

    public init(dependency: VideoCreationDependency, clips: [CompositionClip]) {
        self.clips = clips
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol VideoCreationBuildable: Buildable {
    func build(withListener listener: VideoCreationListener, clips: [CompositionClip]) -> VideoCreationRouting
}

public final class VideoCreationBuilder: Builder<VideoCreationDependency>, VideoCreationBuildable {

    override public init(dependency: VideoCreationDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoCreationListener, clips: [CompositionClip]) -> VideoCreationRouting {
        let component = VideoCreationComponent(dependency: dependency, clips: clips)
        let viewController = VideoCreationViewController()
        let interactor = VideoCreationInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return VideoCreationRouter(interactor: interactor, viewController: viewController, component: component)
    }
}
