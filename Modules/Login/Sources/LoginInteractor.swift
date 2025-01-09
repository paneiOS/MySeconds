//
//  LoginInteractor.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import ModernRIBs

protocol LoginRouting: ViewableRouting {}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

protocol LoginListener: AnyObject {}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable, LoginPresentableListener {

    weak var router: LoginRouting?
    weak var listener: LoginListener?

    override init(presenter: LoginPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
