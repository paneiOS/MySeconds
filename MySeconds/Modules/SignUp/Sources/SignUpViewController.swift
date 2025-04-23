//
//  SignUpViewController.swift
//  MySeconds
//
//  Created by pane on 04/23/2025.
//

import UIKit

import BaseRIBsKit

protocol SignUpPresentableListener: AnyObject {}

final class SignUpViewController: BaseViewController, SignUpPresentable, SignUpViewControllable {

    weak var listener: SignUpPresentableListener?
}
