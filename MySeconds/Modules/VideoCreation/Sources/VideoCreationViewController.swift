//
//  VideoCreationViewController.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import UIKit

import SnapKit

import BaseRIBsKit
import MySecondsKit
import ResourceKit
import UtilsKit

protocol VideoCreationPresentableListener: AnyObject {}

final class VideoCreationViewController: BaseViewController, VideoCreationPresentable, VideoCreationViewControllable {
    private enum Constants {
        static let makeButtonDuration: CGFloat = 1
    }

    weak var listener: VideoCreationPresentableListener?

    private let totalView: UIView = .init()

    private let contentsSubView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.distribution = .fill
        return stackView
    }()

    private let makeButton: UIButton = {
        let button: UIButton = .init()
        var configuration: UIButton.Configuration = .plain()
        configuration.image = ResourceKitAsset.wand.image
        configuration.attributedTitle = .init(.makeAttributedString(
            text: "길게 눌러 만들기",
            font: .systemFont(ofSize: 18, weight: .medium),
            textColor: .white
        ))
        configuration.imagePadding = 8
        configuration.imageColorTransformer = UIConfigurationColorTransformer { _ in .white }
        button.configuration = configuration
        button.backgroundColor = .neutral400
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let titleView: UIView = .init()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "제목",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .neutral600,
            alignment: .center
        )
        return label
    }()

    private lazy var titleTextField: UITextField = {
        let textField: UITextField = .init()
        textField.borderStyle = .none
        textField.attributedPlaceholder = .makeAttributedString(
            text: Date().dateToString,
            font: .systemFont(ofSize: 32, weight: .bold),
            textColor: .neutral400,
            alignment: .center
        )
        textField.textColor = .neutral600
        textField.font = .systemFont(ofSize: 32, weight: .bold)
        textField.textAlignment = .center
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    private var fillLayer: CALayer?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    override func setupUI() {
        super.setupUI()

        self.view.addSubview(self.totalView)
        self.totalView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }

        self.totalView.addSubviews(self.contentsSubView, self.makeButton)
        self.contentsSubView.snp.makeConstraints {
            $0.centerY.leading.trailing.equalToSuperview()
        }
        self.makeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        self.titleView.addSubviews(self.titleLabel, self.titleTextField)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.titleTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.contentsSubView.addArrangedSubview(self.titleView)
    }

    override func bind() {
        super.bind()

        self.makeButton.publisher(for: .touchDown)
            .sink { [weak self] _ in
                guard let self else { return }
                self.startHoldAnimation()
            }
            .store(in: &cancellables)

        self.makeButton.publisher(for: [.touchUpInside, .touchUpOutside, .touchCancel])
            .sink { [weak self] _ in
                guard let self else { return }
                self.endHoldAnimation()
            }
            .store(in: &cancellables)
    }
}

extension VideoCreationViewController {
    private func makeThumbnailView() -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 4
        return imageView
    }
}

extension VideoCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension VideoCreationViewController: CAAnimationDelegate {
    func animationDidStop(_: CAAnimation, finished flag: Bool) {
        if flag {
            self.longPressDidComplete()
        }
    }

    private func startHoldAnimation() {
        self.fillLayer?.removeFromSuperlayer()

        let layer = CALayer()
        layer.backgroundColor = UIColor.neutral800.cgColor
        layer.anchorPoint = .zero
        layer.frame = CGRect(x: 0, y: 0, width: 0, height: self.makeButton.bounds.height)

        self.makeButton.layer.insertSublayer(layer, at: 0)
        self.fillLayer = layer
        self.makeButton.layoutIfNeeded()

        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = 0
        animation.toValue = self.makeButton.bounds.width
        animation.duration = Constants.makeButtonDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        layer.add(animation, forKey: "fillWidth")
    }

    private func endHoldAnimation() {
        self.fillLayer?.removeAllAnimations()
        UIView.animate(withDuration: 0.2) {
            self.fillLayer?.bounds.size.width = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            self.fillLayer?.removeFromSuperlayer()
        }
    }

    private func longPressDidComplete() {
        print("완료")
    }
}
