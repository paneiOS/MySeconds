//
//  AppleSignInService.swift
//  Login
//
//  Created by JeongHwan Lee on 1/12/25.
//

import CryptoKit
import UIKit

import AuthenticationServices
import FirebaseAuth

public final class AppleSignInService: NSObject, SocialLoginService {
    private weak var delegate: SocialLoginDelegate?
    private var currentNonce: String?

    func signIn(viewController: UIViewController? = nil, delegate: SocialLoginDelegate) {
        self.delegate = delegate
        do {
            let nonce = try randomNonceString()
            self.currentNonce = nonce
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.email, .fullName]
            request.nonce = sha256(nonce)
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = viewController as? ASAuthorizationControllerPresentationContextProviding
            authorizationController.performRequests()
        } catch {
            delegate.didFailLogin(with: .unknown(error))
        }

        func randomNonceString(length: Int = 32) throws -> String {
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
                randoms.forEach { random in
                    if remainingLength == 0 { return }

                    if random < charset.count {
                        result.append(charset[Int(random)])
                        remainingLength -= 1
                    }
                }
            }
            return result
        }

        func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            return hashedData.compactMap { String(format: "%02x", $0) }.joined()
        }
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
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
