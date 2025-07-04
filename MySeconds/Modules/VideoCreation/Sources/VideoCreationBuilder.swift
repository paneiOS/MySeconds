//
//  VideoCreationBuilder.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import CoverClipCreation
import SharedModels

public protocol VideoCreationDependency: Dependency {
    var clips: [CompositionClip] { get }
}

public final class VideoCreationComponent: Component<VideoCreationDependency> {
    public var clips: [CompositionClip] { dependency.clips }
}

// MARK: - Builder

public protocol VideoCreationBuildable: Buildable {
    func build(withListener listener: VideoCreationListener) -> VideoCreationRouting
}

public final class VideoCreationBuilder: Builder<VideoCreationDependency>, VideoCreationBuildable {

    override public init(dependency: VideoCreationDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoCreationListener) -> VideoCreationRouting {
        let component = VideoCreationComponent(dependency: dependency)
        let viewController = VideoCreationViewController()
        let interactor = VideoCreationInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return VideoCreationRouter(interactor: interactor, viewController: viewController, component: component)
    }
}
