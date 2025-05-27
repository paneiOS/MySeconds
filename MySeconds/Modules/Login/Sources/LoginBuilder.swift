//
//  LoginBuilder.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import ModernRIBs

public protocol LoginDependency: Dependency {}

public final class LoginComponent: Component<EmptyComponent> {}

// MARK: - Builder

public protocol LoginBuildable: Buildable {
    func build(withListener listener: LoginListener) -> LoginRouting
}

public final class LoginBuilder: Builder<EmptyComponent>, LoginBuildable {

    override public init(dependency: EmptyComponent) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: LoginListener) -> LoginRouting {
        let viewController = LoginViewController()
        viewController.modalPresentationStyle = .fullScreen
        let socialLoginService = DefaultSocialLoginService()
        let interactor = LoginInteractor(
            presenter: viewController,
            socialLoginService: socialLoginService
        )
        interactor.listener = listener

        return LoginRouter(interactor: interactor, viewController: viewController)
    }
}
