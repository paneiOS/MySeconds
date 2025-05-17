//
//  CoverClipCreationViewController.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import UIKit

import SnapKit

import BaseRIBsKit
import MySecondsKit
import ResourceKit
import UtilsKit

protocol CoverClipCreationPresentableListener: AnyObject {}

final class CoverClipCreationViewController: BaseViewControllerWithKeyboard, CoverClipCreationPresentable, CoverClipCreationViewControllable {
    private enum Constants {
        static let clipViewWidth: CGFloat = ceil(UIScreen.main.bounds.width * 160.0 / 393.0)
    }

    // MARK: - UI Components

    private let dimmedView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .clear.withAlphaComponent(0.5)
        return view
    }()

    private let contentsView: UIView = {
        let view: UIView = .init()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private let headerView: UIView = .init()

    private let headerLabel: UILabel = .init()

    private let closeButton: UIButton = {
        let button: UIButton = .init()
        let image: UIImage = ResourceKitAsset.close.image.resized(to: .init(width: 20, height: 20))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.backgroundColor = .init(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 0.2)
        button.tintColor = .init(red: 61 / 255, green: 61 / 255, blue: 61 / 255, alpha: 0.5)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()

    private let clipView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .black
        return view
    }()

    private let preview: UIView = .init()

    private let previewTitleLabel: UILabel = .init()

    private let previewDescriptionLabel: UILabel = .init()

    private let stackView: UIStackView = {
        let view: UIStackView = .init()
        view.axis = .vertical
        view.spacing = 0
        view.alignment = .fill
        view.distribution = .fill
        view.backgroundColor = .neutral200
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    // MARK: - Properties

    weak var listener: CoverClipCreationPresentableListener?
    let coverClip: CoverClip

    // MARK: - init

    init(component: CoverClipCreationComponent) {
        self.coverClip = component.coverClip
        super.init()

        self.drawCoverClip()
    }

    required init?(coder _: NSCoder) { nil }

    // MARK: - Override func

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    override func setupUI() {
        super.setupUI()

        self.view.addSubview(self.dimmedView)
        self.dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.dimmedView.addSubview(self.contentsView)
        self.contentsView.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview()
            $0.leading.trailing.equalToSuperview()
            self.adjustableSnapConstraint = $0.bottom.equalToSuperview().constraint
        }
        self.contentsView.addSubviews(self.headerLabel, self.closeButton, self.clipView, self.stackView)
        self.headerLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
        }
        self.closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(30)
        }
        self.clipView.snp.makeConstraints {
            $0.top.equalTo(self.closeButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Constants.clipViewWidth)
        }
        self.stackView.snp.makeConstraints {
            $0.top.equalTo(self.clipView.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }

        self.clipView.addSubview(self.preview)
        self.preview.addSubviews(self.previewTitleLabel, self.previewDescriptionLabel)
        self.preview.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.previewTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.previewDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.previewTitleLabel.snp.bottom).offset(2)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension CoverClipCreationViewController {
    private func drawCoverClip() {
        self.headerLabel.attributedText = .makeAttributedString(
            text: self.coverClip.position.rawValue,
            font: .systemFont(ofSize: 20, weight: .heavy)
        )
        for (index, item) in [("제목", Date().dateToString), ("설명", "지금은 유럽여행중~")].enumerated() {
            self.stackView.addArrangedSubview(self.makeMultiTextFieldView(title: item.0, placeholder: item.1, index: index))
        }
    }

    private func makeMultiTextFieldView(title: String, placeholder: String, index: Int) -> UIView {
        let view: UIView = .init()
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: title,
            font: .systemFont(ofSize: 17, weight: .regular),
            letterSpacingPercentage: -0.43
        )
        let textField: UITextField = .init()
        textField.attributedPlaceholder = .makeAttributedString(
            text: placeholder,
            font: .systemFont(ofSize: 17, weight: .regular),
            textColor: .neutral400,
            letterSpacingPercentage: -0.43
        )
        textField.tag = index
        textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        view.addSubviews(label, textField)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(11)
        }
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(100)
            $0.top.bottom.equalToSuperview().inset(11)
            $0.trailing.equalToSuperview().inset(16)
        }
        return view
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        switch textField.tag {
        case 0: self.previewTitleLabel.attributedText = .makeAttributedString(
                text: text,
                font: .systemFont(ofSize: 12, weight: .semibold),
                textColor: .white,
                letterSpacingPercentage: -0.43,
                alignment: .center
            )
        case 1: self.previewDescriptionLabel.attributedText = .makeAttributedString(
                text: text,
                font: .systemFont(ofSize: 10, weight: .semibold),
                textColor: .white,
                letterSpacingPercentage: -0.43,
                alignment: .center
            )
        default: break
        }
    }
}
