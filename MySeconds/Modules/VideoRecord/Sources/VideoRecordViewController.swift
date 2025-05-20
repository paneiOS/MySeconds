//
//  VideoRecordViewController.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import Combine
import UIKit

import BaseRIBsKit
import SnapKit

import MySecondsKit
import ResourceKit

protocol VideoRecordPresentableListener: AnyObject {}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, NavigationConfigurable {

    weak var listener: VideoRecordPresentableListener?

    private let cameraControlView: UIView = .init()
    private let albumCountLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "0 / 15",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .neutral500
        )
        return label
    }()

    private let recordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 27
        button.backgroundColor = .red600
        return button
    }()

    private let ratioButton: UIButton = {
        let button = UIButton()
        let size: CGFloat = 48
        button.setTitle("1:1", for: .normal)
        button.setTitleColor(.neutral950, for: .normal)
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = size / 2
        button.layer.borderColor = UIColor.neutral200.toCGColor
        button.layer.borderWidth = 1
        button.snp.makeConstraints { $0.size.equalTo(size) }
        return button
    }()

    private let timerButton: UIButton = {
        let button = UIButton()
        let size: CGFloat = 48
        button.setTitle("촬영\n3초", for: .normal)
        button.setTitleColor(.neutral950, for: .normal)
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = size / 2
        button.layer.borderColor = UIColor.neutral200.toCGColor
        button.layer.borderWidth = 1
        button.snp.makeConstraints { $0.size.equalTo(size) }
        return button
    }()

    private let cameraFlipButton: UIButton = {
        let button = UIButton()
        let size: CGFloat = 48
        button.backgroundColor = .neutral100
        button.layer.cornerRadius = size / 2
        button.layer.borderColor = UIColor.neutral200.toCGColor
        button.layer.borderWidth = 1
        button.setImage(ResourceKitAsset.refreshCcw.image, for: .normal)
        button.tintColor = .neutral950
        button.snp.makeConstraints { $0.size.equalTo(size) }
        return button
    }()

    private let albumView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral100
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.neutral200.toCGColor
        return view
    }()

    override func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubviews(self.cameraControlView)

        let albumStackView = self.createStackView(arrangedSubviews: [self.albumView, self.albumCountLabel], axis: .vertical)
        let buttonStackView = self.createButtonStackView()

        let recordView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 32
            view.layer.borderWidth = 3
            view.layer.borderColor = UIColor.neutral950.toCGColor
            view.addSubview(self.recordButton)
            return view
        }()

        self.cameraControlView.addSubviews(albumStackView, buttonStackView, recordView)

        self.albumView.snp.makeConstraints {
            $0.size.equalTo(64)
        }

        self.cameraControlView.snp.makeConstraints {
            $0.height.equalTo(136)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        self.recordButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(54)
        }

        recordView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(64)
        }

        albumStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }

        buttonStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(96)
        }
    }

    func navigationConfig() -> NavigationConfig {
        NavigationConfig(
            leftButtonType: .logo,
            rightButtonTypes: [
                .custom(
                    image: ResourceKitAsset.image.image,
                    tintColor: .neutral400,
                    action: .push(UIViewController())
                ),
                .custom(
                    image: ResourceKitAsset.menu.image,
                    tintColor: .neutral400,
                    action: .push(UIViewController())
                )
            ]
        )
    }

    private func createStackView(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func createButtonStackView() -> UIStackView {
        let vStackView = self.createStackView(arrangedSubviews: [self.ratioButton, self.cameraFlipButton], axis: .vertical)
        let hStackView = self.createStackView(arrangedSubviews: [self.timerButton, vStackView], axis: .horizontal)

        return hStackView
    }
}

extension UIColor {
    var toCGColor: CGColor {
        self.cgColor
    }
}
