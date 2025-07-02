//
//  AppComponent.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/29/25.
//

import Combine

import FirebaseFirestore
import ModernRIBs

import Login
import SocialLoginKit
import VideoDraftStorage

final class AppComponent: Component<EmptyDependency>, RootDependency, LoginDependency {
    let socialLoginService: SocialLoginService
    let firestore: Firestore
    let storage: VideoDraftStorageDelegate

    init() {
        do {
            self.firestore = .firestore()
            self.socialLoginService = DefaultSocialLoginService()
            self.storage = try VideoDraftStorage()
            super.init(dependency: EmptyComponent())
        } catch {
            // TODO: - 알럿을 이용한 재시작 로직 혹은 종료
            exit(0)
        }
    }
}
