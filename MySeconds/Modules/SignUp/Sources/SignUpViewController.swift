//
//  SignUpViewController.swift
//  MySeconds
//
//  Created by pane on 04/23/2025.
//

import Combine
import UIKit

import SnapKit

import BaseRIBsKit
import MySecondsKit
import ResourceKit
import UtilsKit

protocol SignUpPresentableListener: AnyObject {
    func sendUserInfo(with userInfo: AdditionalUserInfo)
}

final class SignUpViewController: BaseViewController, SignUpPresentable, SignUpViewControllable {
    weak var listener: SignUpPresentableListener?

    private let totalView: UIView = .init()

    private let contentsView: UIView = .init()

    private let contentsSubView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.distribution = .fill
        return stackView
    }()

    private let sendButton: DSButton = {
        let button: DSButton = .init()
        button.setAttributedTitle(
            .makeAttributedString(
                text: "완료",
                font: .systemFont(ofSize: 18, weight: .medium),
                textColor: .white
            ),
            for: .normal
        )
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let titleView: UIView = .init()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "서비스 개선을 위한",
            font: .systemFont(ofSize: 24, weight: .bold),
            textColor: .neutral800,
            alignment: .center
        )
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "정보를 입력해주세요 🤗",
            font: .systemFont(ofSize: 14, weight: .regular),
            textColor: .neutral600,
            alignment: .center
        )
        return label
    }()

    private let ageView: UIView = .init()

    private let ageTitleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "연령대",
            font: .systemFont(ofSize: 16, weight: .medium),
            textColor: .neutral800
        )
        return label
    }()

    private let ageSelectButtonsView: SelectButtonsView = .init(
        buttonTitles: ["10대 미만", "10대", "20대", "30대", "40대", "50대 이상"],
        gridSize: .init(row: 2, column: 3)
    )

    private let maleTitleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "성별",
            font: .systemFont(ofSize: 16, weight: .medium),
            textColor: .neutral800
        )
        return label
    }()

    private let maleView: UIView = .init()

    private let maleSelectButtonsView: SelectButtonsView = .init(
        buttonTitles: ["남성", "여성"],
        gridSize: .init(row: 1, column: 2)
    )

    override func setupUI() {
        super.setupUI()

        self.view.addSubviews(self.totalView)
        self.totalView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }

        self.totalView.addSubviews(self.contentsView, self.sendButton)
        self.contentsView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.sendButton.snp.makeConstraints {
            $0.top.equalTo(self.contentsView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        self.contentsView.addSubview(self.contentsSubView)
        self.contentsSubView.snp.makeConstraints {
            $0.leading.trailing.centerY.equalToSuperview()
        }

        self.titleView.addSubviews(self.titleLabel, self.subtitleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.ageView.addSubviews(self.ageTitleLabel, self.ageSelectButtonsView)
        self.ageTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.ageSelectButtonsView.snp.makeConstraints {
            $0.top.equalTo(self.ageTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.maleView.addSubviews(self.maleTitleLabel, self.maleSelectButtonsView)
        self.maleTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.maleSelectButtonsView.snp.makeConstraints {
            $0.top.equalTo(self.maleTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        for item in [self.titleView, self.ageView, self.maleView] {
            self.contentsSubView.addArrangedSubview(item)
        }
    }

    override func bind() {
        super.bind()

        Publishers.CombineLatest(
            self.ageSelectButtonsView.selectionPublisher,
            self.maleSelectButtonsView.selectionPublisher
        )
        .map { $0 != nil && $1 != nil }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isEnabled in
            guard let self else { return }
            self.sendButton.isEnabled = isEnabled
            self.sendButton.backgroundColor = isEnabled ? .neutral800 : .neutral400
        }
        .store(in: &cancellables)

        self.sendButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self,
                      let age = self.ageSelectButtonsView.selectedValue,
                      let male = self.maleSelectButtonsView.selectedValue else {
                    return
                }
                self.listener?.sendUserInfo(with: .init(age: age, male: male))
            })
            .store(in: &self.cancellables)
    }
}
