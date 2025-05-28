//
//  BGMSelectBuilder.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol BGMSelectDependency: Dependency {}

public final class BGMSelectComponent: Component<BGMSelectDependency> {}

// MARK: - Builder

public protocol BGMSelectBuildable: Buildable {
    func build(withListener listener: BGMSelectListener) -> BGMSelectRouting
}

public final class BGMSelectBuilder: Builder<BGMSelectDependency>, BGMSelectBuildable {

    override public init(dependency: BGMSelectDependency) {
        super.init(dependency: dependency)
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }

    public func build(withListener listener: BGMSelectListener) -> BGMSelectRouting {
        let component = BGMSelectComponent(dependency: dependency)
        let viewController = BGMSelectViewController()
        let interactor = BGMSelectInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return BGMSelectRouter(interactor: interactor, viewController: viewController)
    }
}
