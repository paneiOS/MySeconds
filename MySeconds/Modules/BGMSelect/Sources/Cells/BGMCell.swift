//
//  BGMCell.swift
//  BGMSelect
//
//  Created by 이정환 on 6/1/25.
//

import Combine
import UIKit

import SnapKit

import ResourceKit
import UtilsKit

public final class BGMCell: UICollectionViewCell {
    private let titleView: UIView = .init()
    private let titleLabel: UILabel = .init()
    private let subtitleView: UIStackView = {
        let view: UIStackView = .init()
        view.axis = .horizontal
        view.spacing = 2
        return view
    }()

    private let bpmLabel: InsetLabel = {
        let label: InsetLabel = .init()
        label.backgroundColor = .neutral400
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()

    private let categoryLabel: InsetLabel = {
        let label: InsetLabel = .init()
        label.backgroundColor = .init(red: 239 / 255, green: 178 / 255, blue: 73 / 255, alpha: 1)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()

    private let timeView: UIView = .init()
    private let playTimeLabel: UILabel = .init()
    private let timeDistributionView: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "/",
            font: .systemFont(ofSize: 12, weight: .regular),
            textColor: .neutral600
        )
        return label
    }()

    private let totalPlayTimeLabel: UILabel = .init()

    private let playButton: UIButton = {
        let button: UIButton = .init()
        let image: UIImage = ResourceKitAsset.play.image.resized(to: .init(width: 16, height: 16))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .neutral200
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let applayButton: UIButton = {
        let button: UIButton = .init()
        button.setAttributedTitle(
            .makeAttributedString(
                text: "적용",
                font: .systemFont(ofSize: 14, weight: .medium)
            ),
            for: .normal
        )
        button.backgroundColor = .neutral200
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let playSubject = PassthroughSubject<Bool, Never>()
    public var playPulbisher: AnyPublisher<Bool, Never> {
        self.playSubject.eraseToAnyPublisher()
    }

    private let applySubject = PassthroughSubject<Void, Never>()
    public var applyPublisher: AnyPublisher<Void, Never> {
        self.applySubject.eraseToAnyPublisher()
    }

    public var isPlay: Bool = false {
        didSet {
            let image: UIImage = self.isPlay ? ResourceKitAsset.stop.image : ResourceKitAsset.play.image
            self.playButton.setImage(image.resized(to: .init(width: 16, height: 16)).withRenderingMode(.alwaysTemplate), for: .normal)
            self.playButton.isSelected = self.isPlay
            if !self.isPlay {
                self.playTimeLabel.attributedText = .makeAttributedString(
                    text: "0:00",
                    font: .systemFont(ofSize: 12, weight: .regular),
                    textColor: .neutral600
                )
            }
        }
    }

    public var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) { nil }

    override public func prepareForReuse() {
        super.prepareForReuse()

        self.isPlay = false
    }

    private func setupUI() {
        self.contentView.addSubviews(self.titleView, self.timeView, self.playButton, self.applayButton)
        self.titleView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        self.titleView.addSubviews(self.titleLabel, self.subtitleView)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        self.subtitleView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(2)
            $0.leading.bottom.equalToSuperview()
        }
        for item in [self.bpmLabel, self.categoryLabel] {
            self.subtitleView.addArrangedSubview(item)
        }
        self.timeView.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(self.titleView.snp.trailing)
            $0.centerY.equalToSuperview()
        }
        self.timeView.addSubviews(self.playTimeLabel, self.timeDistributionView, self.totalPlayTimeLabel)
        self.playTimeLabel.snp.makeConstraints {
            $0.leading.greaterThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
        }
        self.timeDistributionView.snp.makeConstraints {
            $0.leading.equalTo(self.playTimeLabel.snp.trailing).offset(2)
            $0.centerY.equalToSuperview()
        }
        self.totalPlayTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(self.timeDistributionView.snp.trailing).offset(2)
            $0.centerY.trailing.equalToSuperview()
        }
        self.playButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.timeView.snp.trailing).offset(8)
            $0.size.equalTo(40)
        }
        self.applayButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.playButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }
    }

    private func bind() {
        self.playButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.playButton.isSelected.toggle()
                self.playSubject.send(self.playButton.isSelected)
                self.isPlay = self.playButton.isSelected
            })
            .store(in: &self.cancellables)

        self.applayButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.applySubject.send()
            })
            .store(in: &self.cancellables)
    }

    func drawCell(model: BGM) {
        self.titleLabel.attributedText = .makeAttributedString(
            text: model.fileName,
            font: .systemFont(ofSize: 14, weight: .medium)
        )
        self.bpmLabel.attributedText = .makeAttributedString(
            text: model.bpmStr,
            font: .systemFont(ofSize: 10, weight: .medium),
            textColor: .white
        )
        self.categoryLabel.attributedText = .makeAttributedString(
            text: model.category,
            font: .systemFont(ofSize: 10, weight: .medium),
            textColor: .white
        )
        self.playTimeLabel.attributedText = .makeAttributedString(
            text: "0:00",
            font: .systemFont(ofSize: 12, weight: .regular),
            textColor: .neutral600
        )
        self.totalPlayTimeLabel.attributedText = .makeAttributedString(
            text: model.durationStr,
            font: .systemFont(ofSize: 12, weight: .regular),
            textColor: .neutral600
        )

        self.cancellables.removeAll()
        self.bind()
    }

    func updatePlayTime(_ time: TimeInterval) {
        self.isPlay = time > 0
        self.playTimeLabel.attributedText = .makeAttributedString(
            text: time.formattedTime,
            font: .systemFont(ofSize: 12, weight: .regular),
            textColor: .neutral600
        )
    }
}

final class InsetLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + self.textInsets.left + self.textInsets.right,
            height: size.height + self.textInsets.top + self.textInsets.bottom
        )
    }
}
