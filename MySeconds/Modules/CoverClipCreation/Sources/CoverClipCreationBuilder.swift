//
//  CoverClipCreationBuilder.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import ModernRIBs

import SharedModels

public protocol CoverClipCreationDependency: Dependency {}

public final class CoverClipCreationComponent: Component<CoverClipCreationDependency> {
    public let videoCoverClip: VideoCoverClip

    public init(dependency: CoverClipCreationDependency, videoCoverClip: VideoCoverClip) {
        self.videoCoverClip = videoCoverClip
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol CoverClipCreationBuildable: Buildable {
    func build(withListener listener: CoverClipCreationListener, videoCoverClip: VideoCoverClip) -> CoverClipCreationRouting
}

public final class CoverClipCreationBuilder: Builder<CoverClipCreationDependency>, CoverClipCreationBuildable {

    override public init(dependency: CoverClipCreationDependency) {
        super.init(dependency: dependency)
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }

    public func build(withListener listener: CoverClipCreationListener, videoCoverClip: VideoCoverClip) -> CoverClipCreationRouting {
        let component = CoverClipCreationComponent(dependency: dependency, videoCoverClip: videoCoverClip)
        let viewController = CoverClipCreationViewController(component: component)
        let interactor = CoverClipCreationInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return CoverClipCreationRouter(interactor: interactor, viewController: viewController)
    }
}
