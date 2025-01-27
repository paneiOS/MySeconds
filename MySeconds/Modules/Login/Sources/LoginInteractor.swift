//
//  LoginInteractor.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import ModernRIBs

import UtilsKit

public protocol LoginRouting: ViewableRouting {}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

public protocol LoginListener: AnyObject {
    func didCompleteLogin(with result: LoginResult)
    func didFailLogin(with error: Error)
    func didRequireAdditionalInfo(with uid: String)
}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable {
    weak var router: LoginRouting?
    weak var listener: LoginListener?

    private let firestore = Firestore.firestore()
    private let appleSignInService: AppleSignInService
    private let googleSignInService: GoogleSignInService

    init(
        presenter: LoginPresentable,
        appleSignInService: AppleSignInService,
        googleSignInService: GoogleSignInService
    ) {
        self.appleSignInService = appleSignInService
        self.googleSignInService = googleSignInService
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension LoginInteractor {
    private func checkUserInFirestore(with authResult: AuthDataResult) {
        let uid = authResult.user.uid
        self.firestore.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self else { return }
            if let document {
                if document.exists {
                    self.listener?.didCompleteLogin(with: .success)
                } else {
                    self.listener?.didCompleteLogin(with: .additionalInfoRequired(uid: uid))
                }
            } else if let error {
                printDebug(error)
            }
        }
    }

    private func checkAdditionalInfo(for document: DocumentSnapshot, uid: String) {
        if let birthDate = document.data()?["birthDate"] as? String,
           !birthDate.isEmpty {
            self.listener?.didCompleteLogin(with: .success)
        } else {
            self.listener?.didCompleteLogin(with: .additionalInfoRequired(uid: uid))
        }
    }
}

extension LoginInteractor: LoginPresentableListener {
    func appleLogin() {
        self.appleSignInService.signIn(delegate: self)
    }

    func googleLogin(with viewController: UIViewController) {
        self.googleSignInService.signIn(viewController: viewController, delegate: self)
    }
}

extension LoginInteractor: SocialLoginDelegate {
    func didSucceedLogin(with authData: FirebaseAuth.AuthDataResult) {
        self.checkUserInFirestore(with: authData)
    }

    func didFailLogin(with error: LoginError) {
        self.listener?.didFailLogin(with: error)
    }
}
