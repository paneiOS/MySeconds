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
    func backButtonTapped() // 뒤로가기
    func mainFirstBtnTapped()
    func mainSecondBtnTapped()
}

public enum NavigationType: Equatable {
    case main
    case title(hasBack: Bool, title: String)
    case search
}

public class NavigationBarView: UIView {
    weak var delegate: NavigationDelegate?
    private var seachPlaceHolder: String
    private lazy var mainView: UIView = {
        let view = UIView()
        return view
    }()

    private var naviType: NavigationType {
        didSet {
            self.setupUI()
        }
    }

    private lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.addTarget(self, action: #selector(self.didTapBackButton), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var firstRightButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "gearshape"), for: .normal)
        btn.addTarget(self, action: #selector(self.didTapFirstRightButton), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    private lazy var secondRightButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "person"), for: .normal)
        btn.addTarget(self, action: #selector(self.didTapSecondRightButton), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    private lazy var rightStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstRightButton, secondRightButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()

    private lazy var searchView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .neutral100
        view.clipsToBounds = true

        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .gray

        let textField = UITextField()
        textField.placeholder = self.seachPlaceHolder
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .gray
        textField.borderStyle = .none
        textField.backgroundColor = .clear

        let stackView = UIStackView(arrangedSubviews: [searchIcon, textField])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center

        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        searchIcon.snp.makeConstraints {
            $0.size.equalTo(20)
        }

        return view
    }()

    public init(naviType: NavigationType = .main, placeHolder: String = "") {
        self.naviType = naviType
        self.seachPlaceHolder = placeHolder
        super.init(frame: .zero)
        self.setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.subviews.forEach { $0.removeFromSuperview() }
        addSubview(self.mainView)

        self.mainView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(48)
        }

        switch self.naviType {
        case .main:
            self.setupMainUI()
        case let .title(hasBack, title):
            self.setupTitleUI(hasBack: hasBack, title: title)
        case .search:
            self.setupSearchUI()
        }
    }

    private func setupMainUI() {
        let logoImageView = UIImageView(image: UIImage(systemName: "bell.fill"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        self.mainView.addSubview(logoImageView)
        self.mainView.addSubview(self.rightStackView)

        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }

        self.rightStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }

        self.rightStackView.isHidden = false
        self.firstRightButton.isHidden = false
        self.secondRightButton.isHidden = false
    }

    private func setupTitleUI(hasBack: Bool, title: String) {
        self.mainView.addSubview(self.titleLabel)
        self.mainView.addSubview(self.rightStackView)

        if hasBack {
            self.mainView.addSubview(self.backButton)
            self.backButton.isHidden = false

            self.backButton.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(10)
                $0.centerY.equalToSuperview()
            }
        }

        self.titleLabel.text = title
        self.titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        self.rightStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }

        self.rightStackView.isHidden = false
        self.firstRightButton.isHidden = false
        self.secondRightButton.isHidden = false
    }

    private func setupSearchUI() {
        self.mainView.addSubview(self.searchView)
        self.mainView.addSubview(self.backButton)
        self.backButton.isHidden = false

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

    @objc func didTapBackButton() {
        self.delegate?.backButtonTapped()
    }

    @objc func didTapFirstRightButton() {
        self.delegate?.mainFirstBtnTapped()
    }

    @objc func didTapSecondRightButton() {
        self.delegate?.mainSecondBtnTapped()
    }
}
