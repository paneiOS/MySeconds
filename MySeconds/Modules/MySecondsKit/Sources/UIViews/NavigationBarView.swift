//
//  NavigationBarView.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 2/19/25.
//

import ResourceKit
import SnapKit
import UIKit

protocol NavigationDelegate: AnyObject {
    func backBtnTapped()
    func mainFirstBtnTapped()
    func mainSecondBtnTapped()
}

public enum NavigationType: Equatable {
    case main
    case title(hasBack: Bool, title: String, hasRightButton: Bool)
    case search
}

public class NavigationBarView: UIView {
    weak var delegate: NavigationDelegate?
    private var searchPlaceholder: String
    private var naviType: NavigationType {
        didSet {
            self.setupUI()
        }
    }

    private lazy var mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backButton = UIComponents.Buttons.NavigationButton(
        image: ResourceKitAsset.chevronLeft.image,
        tintColor: .neutral800,
        action: #selector(didTapBackButton),
        target: self
    )

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var firstRightButton = UIComponents.Buttons.NavigationButton(
        image: ResourceKitAsset.archive.image,
        action: #selector(didTapFirstRightButton),
        target: self
    )

    private lazy var secondRightButton = UIComponents.Buttons.NavigationButton(
        image: ResourceKitAsset.menu.image,
        action: #selector(didTapSecondRightButton),
        target: self
    )

    private lazy var rightStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isHidden = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var searchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .neutral100
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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

    private func setupUI() {
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(self.mainView)

        NSLayoutConstraint.activate([
            self.mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.mainView.topAnchor.constraint(equalTo: topAnchor),
            self.mainView.heightAnchor.constraint(equalToConstant: 48)
        ])

        switch self.naviType {
        case .main:
            self.setupMainUI()
        case let .title(hasBack, title, hasRightButton):
            self.setupTitleUI(hasBack: hasBack, title: title, hasRightButton: hasRightButton)
        case .search:
            self.setupSearchUI()
        }
    }

    private func setupMainUI() {
        let logoImageView = UIImageView(image: ResourceKitAsset.msLogo.image.withRenderingMode(.alwaysTemplate))
        logoImageView.tintColor = .neutral400
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: 24),
            logoImageView.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 96),
            logoImageView.heightAnchor.constraint(equalToConstant: 32)
        ])

        self.rightStackView.isHidden = false
        self.rightStackView.addArrangedSubview(self.firstRightButton)
        self.rightStackView.addArrangedSubview(self.secondRightButton)
        self.mainView.addSubview(self.rightStackView)

        NSLayoutConstraint.activate([
            self.rightStackView.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -16),
            self.rightStackView.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor)
        ])
    }

    private func setupTitleUI(hasBack: Bool, title: String, hasRightButton: Bool) {
        self.titleLabel.text = title
        self.mainView.addSubview(self.titleLabel)

        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.mainView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor)
        ])

        if hasBack {
            self.mainView.addSubview(self.backButton)
            NSLayoutConstraint.activate([
                self.backButton.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: 10),
                self.backButton.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor)
            ])
        }

        if hasRightButton {
            self.rightStackView.isHidden = false
            self.firstRightButton.setImage(ResourceKitAsset.ellipsis.image, for: .normal)
            self.rightStackView.addArrangedSubview(self.firstRightButton)
            self.mainView.addSubview(self.rightStackView)
            NSLayoutConstraint.activate([
                self.rightStackView.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -16),
                self.rightStackView.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor)
            ])
        }
    }

    private func setupSearchUI() {
        let searchIcon = UIImageView(image: ResourceKitAsset.search.image.withRenderingMode(.alwaysTemplate))
        searchIcon.tintColor = .neutral400
        searchIcon.translatesAutoresizingMaskIntoConstraints = false

        let textField = UITextField()
        textField.placeholder = self.searchPlaceholder
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .neutral400
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false

        self.searchView.addSubview(searchIcon)
        self.searchView.addSubview(textField)

        NSLayoutConstraint.activate([
            searchIcon.leadingAnchor.constraint(equalTo: self.searchView.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: self.searchView.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: self.searchView.trailingAnchor, constant: -12),
            textField.centerYAnchor.constraint(equalTo: self.searchView.centerYAnchor)
        ])
        self.mainView.addSubview(self.searchView)
        self.mainView.addSubview(self.backButton)

        NSLayoutConstraint.activate([
            self.backButton.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: 8),
            self.backButton.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor),
            self.searchView.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 8),
            self.searchView.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -24),
            self.searchView.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor),
            self.searchView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func didTapBackButton() { self.delegate?.backBtnTapped()
    }

    @objc private func didTapFirstRightButton() {
        self.delegate?.mainFirstBtnTapped()
    }

    @objc private func didTapSecondRightButton() {
        self.delegate?.mainSecondBtnTapped()
    }
}
