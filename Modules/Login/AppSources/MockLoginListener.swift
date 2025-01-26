//
//  MockLoginListener.swift
//  Login
//
//  Created by 이정환 on 1/10/25.
//

import FirebaseAuth
import Login
import ModernRIBs

final class MockLoginListener: LoginListener {
    func didCompleteLogin(with result: Login.LoginResult) {
        printDebug("MockLoginListener: didCompleteLogin, \(result)")
    }

    func didFailLogin(with error: any Error) {
        printDebug("MockLoginListener: didFailLogin, \(error)")
    }

    func didRequireAdditionalInfo(with uid: String) {
        printDebug("MockLoginListener: didRequireAdditionalInfo, \(uid)")
    }
}
