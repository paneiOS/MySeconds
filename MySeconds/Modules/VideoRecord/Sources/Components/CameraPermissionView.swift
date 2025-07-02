//
//  CameraPermissionView.swift
//  VideoRecord
//
//  Created by Chung Wussup on 6/16/25.
//

import Combine
import UIKit

import ResourceKit

class CameraPermissionView: UIView {
    private var cancellables = Set<AnyCancellable>()
    
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView(image: ResourceKitAsset.cameraOff.image)
        imageView.tintColor = .neutral400
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "카메라 접근 권한이 필요해요",
            font: .systemFont(ofSize: 16, weight: .medium),
            textColor: .init(red: 82 / 255, green: 82 / 255, blue: 82 / 255, alpha: 1),
            alignment: .center
        )
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "설정 → Myseconds에서\n카메라를 허용해주세요",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .init(red: 82 / 255, green: 82 / 255, blue: 82 / 255, alpha: 1),
            alignment: .center
        )
        label.numberOfLines = 0
        return label
    }()
    
    private let openSettinButton: UIButton = {
        let button: UIButton = .init()
        var configuration: UIButton.Configuration = .plain()
        configuration.attributedTitle = .init(.makeAttributedString(
            text: "설정으로 이동",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .blue600
        ))
        button.configuration = configuration
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.bind()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupUI() {
        self.backgroundColor = .white
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [
                cameraImageView,
                titleLabel,
                descriptionLabel,
                openSettinButton
            ])
            stackView.axis = .vertical
            stackView.spacing = 32
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            return stackView
        }()
        
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.cameraImageView.snp.makeConstraints {
            $0.size.equalTo(48)
        }
    }
    
    private func bind() {
        self.openSettinButton
            .publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                if let appSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(appSettingsUrl) {
                        UIApplication.shared.open(appSettingsUrl, options: [:], completionHandler: nil)
                    }
                }
            })
            .store(in: &self.cancellables)
    }    
}
