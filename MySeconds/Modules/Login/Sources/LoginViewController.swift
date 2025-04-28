//
//  LoginViewController.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import AVFoundation
import UIKit

import AuthenticationServices
import GoogleSignIn
import SnapKit

import BaseRIBsKit
import MySecondsKit
import ResourceKit

protocol LoginPresentableListener: AnyObject {
    func appleLogin()
    func googleLogin(with viewController: UIViewController)
}

final class LoginViewController: BaseViewController, LoginPresentable, LoginViewControllable {

    // MARK: - UI Components

    private lazy var totalView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private let topView: UIView = .init()

    private let videoView: UIComponents.Views.VideoView = .init(player: .sampleVideo)

    private lazy var googleSignInButton: GIDSignInButton = {
        let button: GIDSignInButton = .init()
        button.style = .wide
        button.colorScheme = .light
        button.addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
        return button
    }()

    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(self, action: #selector(didTapAppleLogin), for: .touchUpInside)
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
        view.addSubview(self.totalView)
        for item in [self.topView, self.appleSignInButton, self.googleSignInButton] {
            self.totalView.addArrangedSubview(item)
        }
        self.totalView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }

        self.appleSignInButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.appleSignInButton.snp.width).multipliedBy(48.0 / 345.0)
        }

        self.topView.addSubview(self.videoView)
        self.videoView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(118)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.videoView.snp.height).multipliedBy(240.0 / 396.0)
        }
    }
}

extension LoginViewController {
    @objc private func didTapGoogleLogin() {
        self.listener?.googleLogin(with: self)
    }

    @objc private func didTapAppleLogin() {
        self.listener?.appleLogin()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
