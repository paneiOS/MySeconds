//
//  BaseBuilder.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import ModernRIBs

public protocol BaseBuildable: Buildable {
    func build(withListener listener: BaseListener) -> BaseRouting
}

open class BaseBuilder<DependencyType: Dependency>: Builder<DependencyType> {

    override public init(dependency: DependencyType) {
        super.init(dependency: dependency)
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}

extension BaseBuilder: BaseBuildable {
    public func build(withListener listener: BaseListener) -> BaseRouting {
        let viewController = BaseViewController()
        viewController.modalPresentationStyle = .fullScreen
        let interactor = BaseInteractor(
            presenter: viewController
        )
        interactor.listener = listener

        return BaseRouter(interactor: interactor, viewController: viewController)
    }
}
