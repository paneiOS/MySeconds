//
//  RootInteractor.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import Login
import SharedModels
import SignUp
import SocialLoginKit
import UtilsKit

protocol RootRouting: ViewableRouting {
    func routeToLogin()
    func routeToSignUp(uid: String)
    func routeToVideoCreation(clips: [CompositionClip])
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
}

protocol RootListener: AnyObject {}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootPresentableListener {
    weak var router: RootRouting?
    weak var listener: RootListener?

    // TODO: - 백업파일 연결 예정
    private var clips: [CompositionClip] = [
        .cover(.init(title: nil, description: nil, type: .intro)),
        .cover(.init(title: nil, description: nil, type: .outro))
    ]

    override init(presenter: RootPresentable) {
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
            self.router?.routeToVideoCreation(clips: self.clips)
        case let .additionalInfoRequired(uid):
            self.router?.routeToSignUp(uid: uid)
        case let .failure(error):
            printDebug("로그인 실패 \(error)")
        }
    }

    func sendUserInfo(with userInfo: AdditionalUserInfo) {
        printDebug("sendUserInfo 탭: \(userInfo)")
        self.router?.routeToVideoCreation(clips: self.clips)
    }

    func videoCreationDidSelectCoverClip(_ clip: VideoCoverClip) {
        printDebug("videoCreationDidSelectCoverClip 탭: \(clip)")
    }
}
