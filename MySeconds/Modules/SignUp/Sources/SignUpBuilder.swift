//
//  SignUpBuilder.swift
//  MySeconds
//
//  Created by pane on 04/23/2025.
//

import ModernRIBs

public protocol SignUpDependency: Dependency {
    var token: String { get }
}

public final class SignUpComponent: Component<SignUpDependency> {
    public var token: String { dependency.token }
}

// MARK: - Builder

public protocol SignUpBuildable: Buildable {
    func build(withListener listener: SignUpListener) -> SignUpRouting
}

public final class SignUpBuilder: Builder<SignUpDependency>, SignUpBuildable {

    override public init(dependency: SignUpDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: SignUpListener) -> SignUpRouting {
        let component = SignUpComponent(dependency: dependency)
        let viewController = SignUpViewController()
        let interactor = SignUpInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return SignUpRouter(interactor: interactor, viewController: viewController)
    }
}
