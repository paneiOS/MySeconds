//
//  LoginRouter.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import GoogleSignIn
import ModernRIBs

protocol LoginInteractable: Interactable {
    var router: LoginRouting? { get set }
    var listener: LoginListener? { get set }
}

protocol LoginViewControllable: ViewControllable {}

final class LoginRouter: ViewableRouter<LoginInteractor, LoginViewController>, LoginRouting {

    override init(interactor: LoginInteractor, viewController: LoginViewController) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }

    func googleSignIn(completion: @escaping (Result<GIDSignInResult, Error>) -> Void) {
        let presentingVC = self.viewControllable.uiviewController
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let result {
                completion(.success(result))
            } else if let error {
                completion(.failure(error))
            }
        }
    }
}
