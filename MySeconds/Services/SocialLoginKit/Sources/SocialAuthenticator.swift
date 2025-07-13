//
//  SocialAuthenticator.swift
//  Login
//
//  Created by JeongHwan Lee on 1/28/25.
//

import CryptoKit
import UIKit

import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

public protocol SocialLoginService {
    func signIn(type: SocialLoginType, presentView: UIViewController?, delegate: SocialLoginDelegate)
}

public final class DefaultSocialLoginService: NSObject, SocialLoginService {
    private weak var delegate: SocialLoginDelegate?
    private var currentNonce: String?

    public func signIn(type: SocialLoginType, presentView: UIViewController?, delegate: SocialLoginDelegate) {
        switch type {
        case .apple:
            self.delegate = delegate
            do {
                let nonce = try randomNonceString()
                self.currentNonce = nonce
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.email, .fullName]
                request.nonce = sha256(nonce)
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
                authorizationController.presentationContextProvider = presentView as? ASAuthorizationControllerPresentationContextProviding
                authorizationController.performRequests()
            } catch {
                delegate.didFailLogin(with: .unknown(error))
            }
        case .google:
            guard let presentView else {
                delegate.didFailLogin(with: .unknown(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewController is required for Google Sign-In."])))
                return
            }
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                delegate.didFailLogin(with: .missingClientID)
                return
            }

            let configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = configuration
            GIDSignIn.sharedInstance.signIn(withPresenting: presentView) { result, error in
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
}

extension DefaultSocialLoginService {
    private func randomNonceString(length: Int = 32) throws -> String {
        guard length > 0 else { throw LoginError.nonceGenerationFailed }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = try (0 ..< 16).map { _ in
                var random: UInt8 = 0
                if SecRandomCopyBytes(kSecRandomDefault, 1, &random) != errSecSuccess {
                    throw LoginError.nonceGenerationFailed
                }
                return random
            }
            for random in randoms {
                if remainingLength == 0 { continue }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

extension DefaultSocialLoginService: ASAuthorizationControllerDelegate {
    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                self.delegate?.didFailLogin(with: .unknown(NSError(domain: "Nonce", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: Nonce is missing."])))
                return
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                self.delegate?.didFailLogin(with: .invalidToken)
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.delegate?.didFailLogin(with: .unknown(NSError(domain: "TokenSerialization", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string."])))
                return
            }

            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let authResult {
                    self.delegate?.didSucceedLogin(with: authResult)
                } else if let error {
                    self.delegate?.didFailLogin(with: .firebaseAuthFailed(error))
                } else {
                    self.delegate?.didFailLogin(with: .unknown(NSError(domain: "FirebaseAuth", code: -1)))
                }
            }
        }
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        self.delegate?.didFailLogin(with: .appleSignInFailed(error))
    }
}
