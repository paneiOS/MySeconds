//
//  GoogleSignInService.swift
//  Login
//
//  Created by JeongHwan Lee on 1/11/25.
//

import UIKit

import FirebaseAuth
import FirebaseCore
import GoogleSignIn

public final class GoogleSignInService: SocialLoginService {
    private let clientID: String

    init(clientID: String) {
        self.clientID = clientID
    }

    func signIn(
        viewController: UIViewController,
        completion: @escaping (Result<AuthDataResult, LoginError>) -> Void
    ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(LoginError.missingClientID))
            return
        }

        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error {
                completion(.failure(.googleSignInFailed(error)))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                completion(.failure(.invalidToken))
                return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            Auth.auth().signIn(with: credential) { result, error in
                if let result {
                    completion(.success(result))
                } else if let error {
                    completion(.failure(LoginError.firebaseAuthFailed(error)))
                }
            }
        }
    }

    func handleURL(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
