//
//  NavigationBarView.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 2/19/25.
//

import UIKit

import SnapKit

// MARK: - NavigationDelegate

public protocol NavigationDelegate: AnyObject {
    func menuButtonTapped()
    func achiveButtonTapped()
    func ellipseButtonTapped()
    func backButtonTapped()
}
    
// MARK: - NavigationType

public enum NavigationType {
    case main
    case title(hasBack: Bool, title: String, hasRightButton: Bool)
    case search
}

public final class NavigationBarView: UIView {
    // MARK: - UI Components

    private let mainView: UIView = .init()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var backButton: UIButton = {
        let action = UIAction(image: UIImage(resource: ImageResource.chevronLeft)
            .withRenderingMode(.alwaysTemplate)) { _ in
                self.delegate?.achiveButtonTapped()
            }
        let button = UIButton(type: .custom, primaryAction: action)
        button.tintColor = .neutral400
        return button
    }()

    private lazy var archiveButton: UIButton = {
        let action = UIAction(image: UIImage(resource: ImageResource.archive)
            .withRenderingMode(.alwaysTemplate)) { _ in
                self.delegate?.achiveButtonTapped()
            }
        let button = UIButton(type: .custom, primaryAction: action)
        button.tintColor = .neutral400
        return button
    }()

    private lazy var menuButton: UIButton = {
        let action = UIAction(image: UIImage(resource: ImageResource.menu)
            .withRenderingMode(.alwaysTemplate)) { _ in
                self.delegate?.menuButtonTapped()
            }
        let button = UIButton(type: .custom, primaryAction: action)
        button.tintColor = .neutral400
        return button
    }()

    private lazy var ellipsisButton: UIButton = {
        let action = UIAction(image: UIImage(resource: ImageResource.ellipsis)
            .withRenderingMode(.alwaysTemplate)) { _ in
                self.delegate?.ellipseButtonTapped()
            }
        let button = UIButton(type: .custom, primaryAction: action)
        button.tintColor = .black
        return button
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()

    private let searchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .neutral100
        view.clipsToBounds = true
        return view
    }()

    private let logoImageView: UIImageView = {
        let image = UIImage(resource: ImageResource.logo)
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .neutral400
        return imageView
    }()

    private let searchImageView: UIImageView = {
        let image = UIImage(resource: ImageResource.search)
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .neutral400
        return imageView
    }()

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .neutral400
        return textField
    }()

    // MARK: - Properties

    public weak var delegate: NavigationDelegate?
    private let searchPlaceholder: String
    private let naviType: NavigationType

    // MARK: - Init

    public init(
        naviType: NavigationType = .main,
        placeHolder: String = ""
    ) {
        self.naviType = naviType
        self.searchPlaceholder = placeHolder
        super.init(frame: .zero)
        self.setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        self.addSubviews(self.mainView)

        self.mainView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(48)
        }

        switch self.naviType {
        case .main:
            self.setupMainUI()
        case let .title(hasBack, title, hasPrimaryButton):
            self.setupTitleUI(
                hasBack: hasBack,
                title: title,
                hasPrimaryButton: hasPrimaryButton
            )
        case .search:
            self.setupSearchUI()
        }
    }

    private func setupMainUI() {
        self.mainView.addSubviews(self.logoImageView, self.buttonStackView)

        for item in [self.archiveButton, self.menuButton] {
            self.buttonStackView.addArrangedSubview(item)
        }
        self.buttonStackView.isHidden = false

        self.logoImageView.snp.makeConstraints {
            $0.leading.equalTo(self.mainView.snp.leading).inset(24)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(96)
            $0.height.equalTo(32)
        }
        self.buttonStackView.snp.makeConstraints {
            $0.trailing.equalTo(self.mainView.snp.trailing).inset(16)
            $0.centerY.equalToSuperview()
        }
    }

    private func setupTitleUI(hasBack: Bool, title: String, hasPrimaryButton: Bool) {
        self.titleLabel.text = title
        self.mainView.addSubviews(self.titleLabel)

        self.titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        if hasBack {
            self.mainView.addSubviews(self.backButton)
            self.backButton.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(10)
                $0.centerY.equalToSuperview()
            }
        }

        if hasPrimaryButton {
            self.buttonStackView.isHidden = false
            self.buttonStackView.addArrangedSubview(self.ellipsisButton)
            self.mainView.addSubviews(self.buttonStackView)
            self.buttonStackView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
        }
    }

    private func setupSearchUI() {
        self.searchTextField.placeholder = self.searchPlaceholder
        self.searchView.addSubviews(self.searchImageView, self.searchTextField)
        self.mainView.addSubviews(self.searchView, self.backButton)

        self.searchImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        self.searchTextField.snp.makeConstraints {
            $0.leading.equalTo(self.searchImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }

        self.backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }

        self.searchView.snp.makeConstraints {
            $0.leading.equalTo(self.backButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
