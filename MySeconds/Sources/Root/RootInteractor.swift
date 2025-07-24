//
//  RootInteractor.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import Foundation

import ModernRIBs

import BGMSelect
import Login
import ResourceKit
import SharedModels
import SignUp
import SocialLoginKit
import UtilsKit
import VideoDraftStorage
import VideoRecord

protocol RootRouting: ViewableRouting {
    func routeToLogin()
    func routeToSignUp(uid: String)
    func routeToVideoRecord(clips: [CompositionClip])
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
}

protocol RootListener: AnyObject {}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootPresentableListener {
    weak var router: RootRouting?
    weak var listener: RootListener?

    // TODO: - 백업파일 연결 예정
//    private var clips: [CompositionClip] = [
//        .cover(.init(title: nil, description: nil, type: .intro)),
//        .cover(.init(title: nil, description: nil, type: .outro))
//    ]

    private var bgmDirectoryURL: URL? {
        ResourceKitResources.bundle.url(forResource: "BGMs", withExtension: nil)
    }

    private let component: RootComponent

    // TODO: - 키체인 추가후 로그인상태 관리할 것
    private var tempUserID: Int = -99

    init(presenter: RootPresentable, component: RootComponent) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        self.router?.routeToLogin()
    }
}

extension RootInteractor: RootInteractable {
    func didLogin(with result: LoginResult) {
        switch result {
        case .success:
            if self.tempUserID == -99 {
                let loadedClips = (try? self.component.videoDraftStorage.loadAll(type: CompositionClip.self)) ?? []
                self.router?.routeToVideoRecord(clips: loadedClips)
            } else {
                do {
                    try self.component.videoDraftStorage.deleteAll()
                } catch {
                    // TODO: - 기획이 필요해보임
                    print("pane_ 스토리지 데이터 삭제 실패")
                }
                self.router?.routeToVideoRecord(clips: [])
            }
        case let .additionalInfoRequired(uid):
            self.router?.routeToSignUp(uid: uid)
        case let .failure(error):
            printDebug("로그인 실패 \(error)")
        }
    }

    func sendUserInfo(with userInfo: AdditionalUserInfo) {
        if self.tempUserID == -99 {
            let loadedClips = (try? self.component.videoDraftStorage.loadAll(type: CompositionClip.self)) ?? []
            self.router?.routeToVideoRecord(clips: loadedClips)
        } else {
            do {
                try self.component.videoDraftStorage.deleteAll()
            } catch {
                // TODO: - 기획이 필요해보임
                print("pane_ 스토리지 데이터 삭제 실패")
            }
            self.router?.routeToVideoRecord(clips: [])
        }
    }
}
