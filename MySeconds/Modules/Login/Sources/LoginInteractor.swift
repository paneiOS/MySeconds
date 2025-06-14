//
//  LoginInteractor.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import Combine
import UIKit

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import ModernRIBs

import BaseRIBsKit
import SocialLoginKit
import UtilsKit

public protocol LoginRouting: ViewableRouting {}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

public protocol LoginListener: AnyObject {
    func didLogin(with result: LoginResult)
}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable {
    weak var router: LoginRouting?
    weak var listener: LoginListener?

    private let firestore: Firestore
    private let socialLoginService: SocialLoginService

    init(
        presenter: LoginPresentable,
        firestore: Firestore,
        socialLoginService: SocialLoginService
    ) {
        self.socialLoginService = socialLoginService
        self.firestore = firestore
        super.init(presenter: presenter)
        presenter.listener = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}

extension LoginInteractor {
    private func checkUserInFirestore(with authResult: AuthDataResult) {
        let uid = authResult.user.uid
        self.firestore.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self else { return }
            if let document {
                if document.exists {
                    self.listener?.didLogin(with: .success)
                } else {
                    self.listener?.didLogin(with: .additionalInfoRequired(uid: uid))
                }
            } else if let error {
                printDebug(error)
            }
        }
    }

    private func checkAdditionalInfo(for document: DocumentSnapshot, uid: String) {
        if let birthDate = document.data()?["birthDate"] as? String,
           !birthDate.isEmpty {
            self.listener?.didLogin(with: .success)
        } else {
            self.listener?.didLogin(with: .additionalInfoRequired(uid: uid))
        }
    }
}

extension LoginInteractor: LoginPresentableListener {
    func appleLogin() {
        self.socialLoginService.signIn(type: .apple, presentView: nil, delegate: self)
    }

    func googleLogin(with viewController: UIViewController) {
        self.socialLoginService.signIn(type: .google, presentView: viewController, delegate: self)
    }
}

extension LoginInteractor: SocialLoginDelegate {
    func didSucceedLogin(with authData: FirebaseAuth.AuthDataResult) {
        self.checkUserInFirestore(with: authData)
    }

    func didFailLogin(with error: LoginError) {
        self.listener?.didLogin(with: .failure(error))
    }
}
