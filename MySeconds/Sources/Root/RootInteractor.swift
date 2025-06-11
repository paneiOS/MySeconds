//
//  RootInteractor.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import Login
import SharedModels
import UtilsKit

protocol RootRouting: ViewableRouting {
    func routeToLogin()
    func dismissLogin()
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
    private var clips: [CompositionClip] = []

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
    func videoCreationDidSelectCoverClip(_ clip: VideoCoverClip) {
        print("videoCreationDidSelectCoverClip 탭")
    }

    func didLogin(with result: LoginResult) {
        switch result {
        case .success:
            self.router?.dismissLogin()
            self.router?.routeToVideoCreation(clips: self.clips)
        case let .failure(error):
            printDebug("로그인 실패 \(error)")
        case let .additionalInfoRequired(uid):
            printDebug("추가정보 화면 \(uid)")
        }
    }
}
