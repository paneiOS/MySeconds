//
//  SignUpInteractor.swift
//  MySeconds
//
//  Created by pane on 04/23/2025.
//

import ModernRIBs

import FirebaseFirestore

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

    private let component: SignUpComponent

    init(presenter: SignUpPresentable, component: SignUpComponent) {
        self.component = component

        super.init(presenter: presenter)
        presenter.listener = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}

extension SignUpInteractor: SignUpPresentableListener {
    func sendUserInfo(with userInfo: AdditionalUserInfo) {
        let uid = self.component.uid

        let data: [String: String] = [
            "nickname": userInfo.age,
            "gender": userInfo.gender,
            "createdAt": Date().formatted()
        ]

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData(data) { [weak self] error in
                if let error {
                    print("❌ Firestore 업로드 실패: \(error.localizedDescription)")
                } else {
                    print("✅ Firestore 업로드 성공")
                    self?.listener?.sendUserInfo(with: userInfo)
                }
            }
    }
}
