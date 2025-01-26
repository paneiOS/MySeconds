//
//  LoginViewController.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import UIKit

import AuthenticationServices
import GoogleSignIn
import SnapKit

protocol LoginPresentableListener: AnyObject {
    func loginWithGoogle(with viewController: UIViewController)
}

final class LoginViewController: UIViewController, LoginPresentable, LoginViewControllable {
    // MARK: - UI Components

    private lazy var loginStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            googleSignInButton,
            appleSignInButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private lazy var googleSignInButton: GIDSignInButton = {
        let button: GIDSignInButton = .init()
        button.style = .wide
        button.colorScheme = .light
        button.addTarget(self, action: #selector(didTapGoogleSignIn), for: .touchUpInside)
        return button
    }()

    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
//        button.addTarget(self, action: #selector(didTapAppleSignIn), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties

    weak var listener: LoginPresentableListener?

    // MARK: - Override func

    override func viewDidLoad() {
        super.viewDidLoad()

        self.makeUI()
    }

    private func makeUI() {
        view.backgroundColor = .white
        view.addSubview(self.loginStackView)

        self.loginStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
}

extension LoginViewController {
    @objc private func didTapGoogleSignIn() {
        self.listener?.loginWithGoogle(with: self)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// TODO: - 임시

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}

public func printDebug(
    _ message: Any,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[DEBUG] fileName: \(fileName) ::: line: \(line) ::: func: \(function) -> \(message)")
    #endif
}
