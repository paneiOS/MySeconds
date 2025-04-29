//
//  VideoCreationBuilder.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol VideoCreationDependency: Dependency {}

public final class VideoCreationComponent: Component<VideoCreationDependency> {}

extension VideoCreationComponent: VideoCreationDependency {}

// MARK: - Builder

public protocol VideoCreationBuildable: Buildable {
    func build(withListener listener: VideoCreationListener) -> VideoCreationRouting
}

public final class VideoCreationBuilder: BaseBuilder<VideoCreationComponent>, VideoCreationBuildable {

    override public init(dependency: VideoCreationComponent) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoCreationListener) -> VideoCreationRouting {
        let component = VideoCreationComponent(dependency: dependency)
        let viewController = VideoCreationViewController()
        let interactor = VideoCreationInteractor(presenter: viewController, component: dependency)
        interactor.listener = listener
        return VideoCreationRouter(interactor: interactor, viewController: viewController)
    }
}
