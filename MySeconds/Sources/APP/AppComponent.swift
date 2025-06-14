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

final class AppComponent: Component<EmptyDependency>, RootDependency, LoginDependency {
    let socialLoginService: SocialLoginService
    let firestore: Firestore

    init() {
        self.firestore = .firestore()
        self.socialLoginService = DefaultSocialLoginService()
        super.init(dependency: EmptyComponent())
    }
}
