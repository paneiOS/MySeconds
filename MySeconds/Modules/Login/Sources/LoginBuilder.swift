//
//  LoginBuilder.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import FirebaseFirestore
import ModernRIBs

import SocialLoginKit

public protocol LoginDependency: Dependency {
    var socialLoginService: SocialLoginService { get }
    var firestore: Firestore { get }
}

public final class LoginComponent: Component<LoginDependency> {}

// MARK: - Builder

public protocol LoginBuildable: Buildable {
    func build(withListener listener: LoginListener) -> LoginRouting
}

public final class LoginBuilder: Builder<LoginDependency>, LoginBuildable {

    override public init(dependency: LoginDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: LoginListener) -> LoginRouting {
        let component = LoginComponent(dependency: self.dependency)
        let viewController = LoginViewController()
        let interactor = LoginInteractor(
            presenter: viewController,
            firestore: component.dependency.firestore,
            socialLoginService: component.dependency.socialLoginService
        )
        interactor.listener = listener

        return LoginRouter(interactor: interactor, viewController: viewController)
    }
}
