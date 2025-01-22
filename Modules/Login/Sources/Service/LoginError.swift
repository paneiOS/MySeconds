//
//  LoginError.swift
//  Login
//
//  Created by JeongHwan Lee on 1/12/25.
//

import Foundation

enum LoginError: Error {
    case missingClientID
    case googleSignInFailed(Error)
    case appleSignInFailed(Error)
    case firebaseAuthFailed(Error)
    case invalidToken
    case unknown(Error)

    var localizedDescription: String {
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
        case let .unknown(error):
            "알 수 없는 오류가 발생했습니다., \(error.localizedDescription)"
        }
    }
}
