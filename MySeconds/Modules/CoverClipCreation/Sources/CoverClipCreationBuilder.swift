//
//  CoverClipCreationBuilder.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol CoverClipCreationDependency: Dependency {
    var coverClip: CoverClip { get }
}

public final class CoverClipCreationComponent: Component<CoverClipCreationDependency> {
    public var coverClip: CoverClip { dependency.coverClip }
}

extension CoverClipCreationComponent: CoverClipCreationDependency {}

// MARK: - Builder

public protocol CoverClipCreationBuildable: Buildable {
    func build(withListener listener: CoverClipCreationListener) -> CoverClipCreationRouting
}

public final class CoverClipCreationBuilder: BaseBuilder<CoverClipCreationComponent>, CoverClipCreationBuildable {

    override public init(dependency: CoverClipCreationComponent) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: CoverClipCreationListener) -> CoverClipCreationRouting {
        let component = CoverClipCreationComponent(dependency: dependency)
        let viewController = CoverClipCreationViewController(component: component)
        let interactor = CoverClipCreationInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return CoverClipCreationRouter(interactor: interactor, viewController: viewController)
    }
}
