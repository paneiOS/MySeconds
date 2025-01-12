//
//  SocialLoginService.swift
//  Login
//
//  Created by JeongHwan Lee on 1/11/25.
//

import UIKit

import FirebaseAuth

protocol SocialLoginService {
    func signIn(viewController: UIViewController, completion: @escaping (Result<AuthDataResult, LoginError>) -> Void)
    func handleURL(_ url: URL) -> Bool
}
