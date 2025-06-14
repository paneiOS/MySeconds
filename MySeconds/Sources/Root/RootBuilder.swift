//
//  RootBuilder.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import FirebaseFirestore
import Login
import SignUp
import SocialLoginKit
import VideoCreation

protocol RootDependency: Dependency {
    var socialLoginService: SocialLoginService { get }
    var firestore: Firestore { get }
}

final class RootComponent: Component<RootDependency> {}

extension RootComponent: LoginDependency {
    var firestore: Firestore {
        dependency.firestore
    }

    var socialLoginService: SocialLoginService {
        dependency.socialLoginService
    }

    var loginBuilder: LoginBuildable {
        LoginBuilder(dependency: self)
    }
}

extension RootComponent: VideoCreationDependency {
    var videoCreationBuilder: VideoCreationBuildable {
        VideoCreationBuilder(dependency: self)
    }
}

extension RootComponent: SignUpDependency {
    var signUpBuilder: SignUpBuildable {
        SignUpBuilder(dependency: self)
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
