//
//  RootInteractor.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import ModernRIBs

import Login
import UtilsKit

protocol RootRouting: ViewableRouting {
    func attachLogin()
    func detachLogin()
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
}

protocol RootListener: AnyObject {}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootPresentableListener {

    weak var router: RootRouting?
    weak var listener: RootListener?

    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        self.router?.attachLogin()
    }
}

extension RootInteractor: RootInteractable {
    func didLogin(with result: LoginResult) {
        printDebug("로그인 결과 \(result)")
        self.router?.detachLogin()
    }
}
