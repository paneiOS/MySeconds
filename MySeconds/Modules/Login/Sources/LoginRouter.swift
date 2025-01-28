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

final class LoginRouter: ViewableRouter<LoginInteractable, LoginViewControllable>, LoginRouting {
    override init(interactor: LoginInteractable, viewController: LoginViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func googleSignIn(completion: @escaping (Result<GIDSignInResult, Error>) -> Void) {
        let presentingVC: UIViewController = self.viewController.uiviewController
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let result {
                completion(.success(result))
            } else if let error {
                completion(.failure(error))
            }
        }
    }
}
