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
    func didCompleteLogin(result _: AuthDataResult) {
        print("MockLoginListener: didCompleteLogin called")
    }
}
