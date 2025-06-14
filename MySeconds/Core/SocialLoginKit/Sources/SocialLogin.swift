//
//  SocialLogin.swift
//  Login
//
//  Created by JeongHwan Lee on 1/11/25.
//

import UIKit

import FirebaseAuth

public protocol SocialLoginDelegate: AnyObject {
    func didSucceedLogin(with authData: AuthDataResult)
    func didFailLogin(with error: LoginError)
}

public enum SocialLoginType {
    case apple
    case google
}

public enum LoginResult {
    case success
    case additionalInfoRequired(uid: String)
    case failure(LoginError)
}

public enum LoginError: LocalizedError {
    case missingClientID
    case googleSignInFailed(Error)
    case appleSignInFailed(Error)
    case firebaseAuthFailed(Error)
    case invalidToken
    case nonceGenerationFailed
    case unknown(Error?)

    public var errorDescription: String? {
        switch self {
        case .missingClientID:
            "Google Client ID가 누락되었습니다."
        case let .googleSignInFailed(error):
            "Google 로그인 실패: \(error.localizedDescription)"
        case let .appleSignInFailed(error):
            "Apple 로그인 실패: \(error.localizedDescription)"
        case let .firebaseAuthFailed(error):
            "Firebase 인증 실패: \(error.localizedDescription)"
        case .invalidToken:
            "User Token 가져오기 실패"
        case .nonceGenerationFailed:
            "Nonce 생성에 실패했습니다."
        case let .unknown(error):
            "알 수 없는 오류가 발생했습니다., \(error?.localizedDescription ?? "")"
        }
    }
}
