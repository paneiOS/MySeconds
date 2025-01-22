////
////  AppleSignInService.swift
////  Login
////
////  Created by JeongHwan Lee on 1/12/25.
////
//
// import UIKit
//
// import FirebaseAuth
// import AuthenticationServices
//
// final class AppleSignInService: NSObject, SocialLoginService {
////    private var currentNonce: String?
//
//
//    func signIn(viewController: UIViewController,
//                completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
//        let request = ASAuthorizationAppleIDProvider().createRequest()
//        request.requestedScopes = [.fullName, .email]
//        currentNonce = randomNonceString()
//        request.nonce = sha256(currentNonce!)
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = viewController as? ASAuthorizationControllerPresentationContextProviding
//        authorizationController.performRequests()
//    }
//
//    func handleURL(_ url: URL) -> Bool {
//        // Apple 로그인은 URL 핸들링이 필요하지 않음.
//        return false
//    }
//
//    private func randomNonceString(length: Int = 32) -> String { /* ... */ }
//    private func sha256(_ input: String) -> String { /* ... */ }
// }
//
// extension AppleSignInService: ASAuthorizationControllerDelegate {
//    func authorizationController(controller _: ASAuthorizationController,
//                                 didCompleteWithAuthorization authorization _: ASAuthorization) { /* ... */ }
// }
