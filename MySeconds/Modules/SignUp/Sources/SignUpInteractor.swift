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

public protocol SignUpListener: AnyObject {}

final class SignUpInteractor: PresentableInteractor<SignUpPresentable>, SignUpInteractable, SignUpPresentableListener {

    weak var router: SignUpRouting?
    weak var listener: SignUpListener?

    init(presenter: SignUpPresentable, component: SignUpComponent) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
