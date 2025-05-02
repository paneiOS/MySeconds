//
//  SignUpInteractor.swift
//  MySeconds
//
//  Created by pane on 04/23/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol SignUpRouting: ViewableRouting {}

protocol SignUpPresentable: Presentable {
    var listener: SignUpPresentableListener? { get set }
}

public protocol SignUpListener: AnyObject {
    func sendUserInfo(with userInfo: AdditionalUserInfo)
}

final class SignUpInteractor: PresentableInteractor<SignUpPresentable>, SignUpInteractable {

    weak var router: SignUpRouting?
    weak var listener: SignUpListener?

    init(presenter: SignUpPresentable, component _: SignUpComponent) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension SignUpInteractor: SignUpPresentableListener {
    func sendUserInfo(with userInfo: AdditionalUserInfo) {
        self.listener?.sendUserInfo(with: userInfo)
    }
}
