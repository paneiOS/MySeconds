//
//  RootBuilder.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import BGMSelect
import CoverClipCreation
import FirebaseFirestore
import Login
import SignUp
import SocialLoginKit
import VideoCreation
import VideoDraftStorage
import VideoRecord

protocol RootDependency: Dependency {
    var socialLoginService: SocialLoginService { get }
    var firestore: Firestore { get }
    var storage: VideoDraftStorageDelegate { get }
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

    var storage: VideoDraftStorageDelegate {
        dependency.storage
    }
}

extension RootComponent: VideoRecordDependency {
    var videoRecordBuilder: VideoRecordBuildable {
        VideoRecordBuilder(dependency: self)
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

extension RootComponent: CoverClipCreationDependency {
    var coverClipCreationBuilder: CoverClipCreationBuildable {
        CoverClipCreationBuilder(dependency: self)
    }
}

extension RootComponent: BGMSelectDependency {
    var bgmSelectBuilder: BGMSelectBuildable {
        BGMSelectBuilder(dependency: self)
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
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen

        let interactor = RootInteractor(presenter: viewController, component: component)
        let router = RootRouter(
            interactor: interactor,
            viewController: navigationController,
            component: component
        )
        return router
    }
}
