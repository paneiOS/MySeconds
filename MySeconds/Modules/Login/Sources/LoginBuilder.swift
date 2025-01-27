//
//  LoginBuilder.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import ModernRIBs

public protocol LoginDependency: Dependency {
    var appleSignInService: AppleSignInService { get }
    var googleSignInService: GoogleSignInService { get }
}

final class LoginComponent: Component<LoginDependency> {
    var appleSignInService: AppleSignInService { dependency.appleSignInService }
    var googleSignInService: GoogleSignInService { dependency.googleSignInService }
}

// MARK: - Builder

protocol LoginBuildable: Buildable {
    func build(withListener listener: LoginListener) -> LoginRouting
}

public final class LoginBuilder: Builder<LoginDependency>, LoginBuildable {
    override public init(dependency: LoginDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: LoginListener) -> LoginRouting {
        let component = LoginComponent(dependency: dependency)
        let viewController = LoginViewController()
        let interactor = LoginInteractor(
            presenter: viewController,
            appleSignInService: component.appleSignInService,
            googleSignInService: component.googleSignInService
        )
        interactor.listener = listener
        return LoginRouter(interactor: interactor, viewController: viewController)
    }
}

extension EmptyComponent: LoginDependency {
    public var appleSignInService: AppleSignInService {
        .init()
    }

    public var googleSignInService: GoogleSignInService {
        .init()
    }
}
