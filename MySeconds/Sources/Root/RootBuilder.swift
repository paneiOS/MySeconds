//
//  RootBuilder.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import Login

protocol RootDependency: Dependency {}

final class RootComponent: Component<RootDependency>, LoginDependency {

    var loginBuilder: LoginBuildable {
        LoginBuilder(dependency: EmptyComponent())
    }
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let component = RootComponent(dependency: self.dependency)
        let viewController = RootViewController()
        viewController.modalPresentationStyle = .fullScreen
        let interactor = RootInteractor(presenter: viewController)
        let router = RootRouter(
            interactor: interactor,
            viewController: viewController,
            component: component
        )
        return router
    }
}
