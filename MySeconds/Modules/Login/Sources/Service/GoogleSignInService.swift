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
    func signIn(viewController: UIViewController?, delegate: SocialLoginDelegate) {
        guard let viewController else {
            delegate.didFailLogin(with: .unknown(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewController is required for Google Sign-In."])))
            return
        }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            delegate.didFailLogin(with: .missingClientID)
            return
        }

        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let user = result?.user {
                guard let idToken = user.idToken?.tokenString else {
                    delegate.didFailLogin(with: .invalidToken)
                    return
                }
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                Auth.auth().signIn(with: credential) { result, error in
                    if let result {
                        delegate.didSucceedLogin(with: result)
                    } else if let error {
                        delegate.didFailLogin(with: .firebaseAuthFailed(error))
                    }
                }
            } else if let error {
                delegate.didFailLogin(with: .googleSignInFailed(error))
            } else {
                delegate.didFailLogin(with: .unknown(nil))
            }
        }
    }
}
