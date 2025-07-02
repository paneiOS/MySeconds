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
import VideoRecord
import VideoRecordingManager

final class AppComponent: Component<EmptyDependency>, RootDependency, LoginDependency, VideoRecordDependency {
    let firestore: Firestore
    let socialLoginService: SocialLoginService
    let videoDraftStorage: VideoDraftStorageDelegate
    let videoRecordingManager: VideoRecordingManagerProtocol

    init() {
        do {
            self.firestore = .firestore()
            self.socialLoginService = DefaultSocialLoginService()
            self.videoDraftStorage = try VideoDraftStorage()
            self.videoRecordingManager = VideoRecordingManager()
            super.init(dependency: EmptyComponent())
        } catch {
            // TODO: - 알럿을 이용한 재시작 로직 혹은 종료
            exit(0)
        }
    }
}
