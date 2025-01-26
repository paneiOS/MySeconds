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

public protocol LoginRouting: ViewableRouting {}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

public protocol LoginListener: AnyObject {
    func didCompleteLogin(with result: LoginResult)
    func didFailLogin(with error: Error)
    func didRequireAdditionalInfo(with uid: String)
}

public enum LoginResult {
    case success
    case additionalInfoRequired(uid: String)
    case failure(Error)
}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable {
    weak var router: LoginRouting?
    weak var listener: LoginListener?

    private let firestore = Firestore.firestore()

    private let googleSignInService: GoogleSignInService

    init(
        presenter: LoginPresentable,
        googleSignInService: GoogleSignInService
    ) {
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
            if let error {
                printDebug(error)
            } else if let document, document.exists {
                self.listener?.didCompleteLogin(with: .success)
            } else {
                self.listener?.didCompleteLogin(with: .additionalInfoRequired(uid: uid))
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
    func loginWithGoogle(with viewController: UIViewController) {
        self.googleSignInService.signIn(viewController: viewController) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(signInResult):
                self.checkUserInFirestore(with: signInResult)
            case let .failure(error):
                self.listener?.didCompleteLogin(with: .failure(error))
            }
        }
    }

//    func loginWithApple() {
//        guard let topViewController = UIApplication.shared.windows.first?.rootViewController else { return }
//
//        appleSignInService.signIn(presentingViewController: topViewController) { result in
//            switch result {
//            case .success(let authData):
//                print("Apple Login Success:", authData.user.uid)
//            case .failure(let error):
//                print("Apple Login Failed:", error.localizedDescription)
//            }
//        }
//    }
}
