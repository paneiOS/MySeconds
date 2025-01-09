//
//  LoginViewController.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import UIKit

import ModernRIBs

protocol LoginPresentableListener: AnyObject {}

final class LoginViewController: UIViewController, LoginPresentable, LoginViewControllable {

    weak var listener: LoginPresentableListener?
}
