//
//  VideoRecordBuilder.swift
//  MySeconds
//
//  Created by chungwussup on 02/18/2025.
//

import ModernRIBs

protocol VideoRecordDependency: Dependency {}

final class VideoRecordComponent: Component<VideoRecordDependency> {}

// MARK: - Builder

protocol VideoRecordBuildable: Buildable {
    func build(withListener listener: VideoRecordListener) -> VideoRecordRouting
}

final class VideoRecordBuilder: Builder<VideoRecordDependency>, VideoRecordBuildable {

    override init(dependency: VideoRecordDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: VideoRecordListener) -> VideoRecordRouting {
        let component = VideoRecordComponent(dependency: dependency)
        let viewController = VideoRecordViewController()
        let interactor = VideoRecordInteractor(presenter: viewController)
        interactor.listener = listener
        return VideoRecordRouter(interactor: interactor, viewController: viewController)
    }
}
