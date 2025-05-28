//
//  VideoRecordBuilder.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol VideoRecordDependency: Dependency {}

public final class VideoRecordComponent: Component<VideoRecordDependency> {}

extension VideoRecordComponent: VideoRecordDependency {}

// MARK: - Builder

public protocol VideoRecordBuildable: Buildable {
    func build(withListener listener: VideoRecordListener) -> VideoRecordRouting
}

public final class VideoRecordBuilder: BaseBuilder<VideoRecordComponent>, VideoRecordBuildable {

    override public init(dependency: VideoRecordComponent) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: VideoRecordListener) -> VideoRecordRouting {
        let component = VideoRecordComponent(dependency: dependency)
        let viewController = VideoRecordViewController()
        let interactor = VideoRecordInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return VideoRecordRouter(interactor: interactor, viewController: viewController)
    }
}
