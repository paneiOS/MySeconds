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
    func backBtnTapped()
    func primaryButtonTapped()
    func secondaryButtonTapped()
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
    private lazy var backButton = UIComponents.Buttons.NavigationButton(
        image: UIImage(named: "chevronLeft", in: bundle, compatibleWith: nil),
        tintColor: .neutral800,
        action: #selector(didTapBackButton),
        target: self
    )

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var primaryButton = UIComponents.Buttons.NavigationButton(
        image: UIImage(named: "archive", in: bundle, compatibleWith: nil),
        action: #selector(didTapPrimaryButton),
        target: self
    )

    private lazy var secondaryButton = UIComponents.Buttons.NavigationButton(
        image: UIImage(named: "menu", in: bundle, compatibleWith: nil),
        action: #selector(didTapSecondaryButton),
        target: self
    )

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

    // MARK: - Properties
    
    public weak var delegate: NavigationDelegate?
    private let searchPlaceholder: String
    private let naviType: NavigationType
    private let bundle = Bundle.module
    
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
            self.setupTitleUI(hasBack: hasBack, title: title, hasPrimaryButton: hasPrimaryButton)
        case .search:
            self.setupSearchUI()
        }
    }

    private func setupMainUI() {
        guard let image = UIImage(named: "logo", in: bundle, compatibleWith: nil) else {
            return
        }

        let logoImageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        logoImageView.tintColor = .neutral400

        self.mainView.addSubviews(logoImageView, self.buttonStackView)

        [self.primaryButton, self.secondaryButton].forEach {
            self.buttonStackView.addArrangedSubview($0)
        }
        self.buttonStackView.isHidden = false

        logoImageView.snp.makeConstraints {
            $0.leading.equalTo(self.mainView.snp.leading).offset(24)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(96)
            $0.height.equalTo(32)
        }
        self.buttonStackView.snp.makeConstraints {
            $0.trailing.equalTo(self.mainView.snp.trailing).offset(-16)
            $0.centerY.equalToSuperview()
        }
    }

    private func setupTitleUI(hasBack: Bool, title: String, hasPrimaryButton: Bool) {
        self.titleLabel.text = title
        self.mainView.addSubviews(self.titleLabel)

        self.titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        if hasBack {
            self.mainView.addSubviews(self.backButton)

            self.backButton.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(10)
                $0.centerY.equalToSuperview()
            }
        }

        if hasPrimaryButton {
            guard let ellipsisImage = UIImage(named: "ellipsis",
                                              in: bundle,
                                              compatibleWith: nil) else {
                return
            }
            self.buttonStackView.isHidden = false
            self.primaryButton.setImage(ellipsisImage, for: .normal)
            self.buttonStackView.addArrangedSubview(self.primaryButton)
            self.mainView.addSubviews(self.buttonStackView)
            self.buttonStackView.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-16)
                $0.centerY.equalToSuperview()
            }
        }
    }

    private func setupSearchUI() {
        guard let searchImage = UIImage(named: "search", in: bundle, compatibleWith: nil) else {
            return
        }
        let searchIcon = UIImageView(image: searchImage.withRenderingMode(.alwaysTemplate))
        searchIcon.tintColor = .neutral400

        let textField = UITextField()
        textField.placeholder = self.searchPlaceholder
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .neutral400

        self.searchView.addSubviews(searchIcon, textField)
        self.mainView.addSubviews(self.searchView, self.backButton)

        searchIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        textField.snp.makeConstraints {
            $0.leading.equalTo(searchIcon.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }

        self.backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
        }

        self.searchView.snp.makeConstraints {
            $0.leading.equalTo(self.backButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
    }

    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        self.delegate?.backBtnTapped()
    }

    @objc private func didTapPrimaryButton() {
        self.delegate?.primaryButtonTapped()
    }

    @objc private func didTapSecondaryButton() {
        self.delegate?.secondaryButtonTapped()
    }
}
