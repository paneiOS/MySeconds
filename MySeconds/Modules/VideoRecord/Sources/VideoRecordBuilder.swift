//
//  VideoRecordBuilder.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import UIKit

import ModernRIBs

import BaseRIBsKit

public protocol VideoRecordDependency: Dependency {
    var initialAlbumThumbnail: UIImage? { get }
    var initialAlbumCount: Int { get }
}

public final class VideoRecordComponent: Component<VideoRecordDependency> {
    public var initialAlbumThumbnail: UIImage? {
        dependency.initialAlbumThumbnail
    }

    public var initialAlbumCount: Int {
        dependency.initialAlbumCount
    }
}

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
