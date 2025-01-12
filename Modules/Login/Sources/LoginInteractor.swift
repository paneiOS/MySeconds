//
//  LoginInteractor.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import UIKit

import FirebaseAuth
import ModernRIBs

public protocol LoginRouting: ViewableRouting {
    func processGoogleSignInURL(_ url: URL)
}

protocol LoginPresentable: Presentable {
    var listener: LoginPresentableListener? { get set }
}

public protocol LoginListener: AnyObject {
    func didCompleteLogin(result: AuthDataResult)
}

final class LoginInteractor: PresentableInteractor<LoginPresentable>, LoginInteractable {

    weak var router: LoginRouting?
    weak var listener: LoginListener?

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

extension LoginInteractor: LoginPresentableListener {
    func isUserLoggedIn() -> Bool {
        Auth.auth().currentUser != nil
    }

    func loginWithGoogle(with viewController: UIViewController) {
        self.googleSignInService.signIn(viewController: viewController) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(data):
                self.listener?.didCompleteLogin(result: data)
            case let .failure(error):
                print("Google Login Failed:", error.localizedDescription)
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
