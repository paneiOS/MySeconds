//
//  CoverClipCreationViewController.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import Combine
import UIKit

import SnapKit

import BaseRIBsKit
import ComponentsKit
import ResourceKit
import SharedModels
import UtilsKit

protocol CoverClipCreationPresentableListener: AnyObject {
    var coverTypePublisher: AnyPublisher<VideoCoverClip.CoverType, Never> { get }
    func initCoverClipCreation()
    func closeButtonTapped()
    func addButtonTapped(clip: VideoCoverClip)
}

final class CoverClipCreationViewController: BaseBottomSheetViewController, CoverClipCreationPresentable, CoverClipCreationViewControllable, KeyboardAdjustable {
    private enum Constants {
        static let clipViewWidth: CGFloat = ceil(UIScreen.main.bounds.width * 160.0 / 393.0)
    }

    private enum Preview {
        enum Title {
            static let size: CGFloat = 12.0
            static let weight: UIFont.Weight = .semibold
        }

        enum Description {
            static let size: CGFloat = 10.0
            static let weight: UIFont.Weight = .semibold
        }
    }

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

    private let fontLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "폰트",
            font: .systemFont(ofSize: 15, weight: .init(590)),
            textColor: .init(red: 60 / 255, green: 60 / 255, blue: 60 / 255, alpha: 0.6),
            letterSpacingPercentage: -0.23
        )
        return label
    }()

    private lazy var fontCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.itemSize = CGSize(width: 80, height: 56)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        layout.scrollDirection = .horizontal
        let view: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.register(FontCell.self, forCellWithReuseIdentifier: FontCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    private let addButton: DSButton = {
        let button: DSButton = .init()
        button.setTitle("추가하기", for: .normal)
        button.isSelected = true
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    // MARK: - Properties

    weak var listener: CoverClipCreationPresentableListener?
    private var clipCoverType: VideoCoverClip.CoverType?
    private var selectedFont: FontRepresentable = UIFont.systemFont(ofSize: Preview.Title.size, weight: Preview.Title.weight) {
        didSet {
            self.updateTextField(represent: self.selectedFont)
        }
    }

    var adjustableConstraint: NSLayoutConstraint? {
        adjustableSnapConstraint?.layoutConstraints.first
    }

    // MARK: - Override func

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    override func setupUI() {
        super.setupUI()

        self.sheetContainerView.addSubviews(self.clipView, self.stackView, self.fontLabel, self.fontCollectionView, self.addButton)
        self.clipView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Constants.clipViewWidth)
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
        self.stackView.snp.makeConstraints {
            $0.top.equalTo(self.clipView.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview()
        }
        self.fontLabel.snp.makeConstraints {
            $0.top.equalTo(self.stackView.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview()
        }
        self.fontCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.fontLabel.snp.bottom).offset(7)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        self.addButton.snp.makeConstraints {
            $0.top.equalTo(self.fontCollectionView.snp.bottom).offset(40)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }
        DispatchQueue.main.async {
            self.fontCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
        }
    }

    override func bind() {
        super.bind()

        self.viewDidLoadPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.initCoverClipCreation()
            })
            .store(in: &self.cancellables)

        self.listener?.coverTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] coverType in
                guard let self else { return }
                self.clipCoverType = coverType
                self.headerLabel.attributedText = .makeAttributedString(
                    text: coverType.rawValue,
                    font: .systemFont(ofSize: 20, weight: .heavy)
                )
                let placeholders = [("제목", Date().dateToString), ("설명", "지금은 여행중~")]
                for (index, item) in placeholders.enumerated() {
                    self.stackView.addArrangedSubview(self.makeMultiTextFieldView(title: item.0, placeholder: item.1, index: index))
                }
            })
            .store(in: &self.cancellables)

        self.closeTappedPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.closeButtonTapped()
            })
            .store(in: &self.cancellables)

        self.addButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self, let clipCoverType else { return }
                let videoCoverClip: VideoCoverClip = .init(
                    title: self.previewTitleLabel.attributedText,
                    description: self.previewDescriptionLabel.attributedText,
                    type: clipCoverType
                )
                view.endEditing(true)
                self.listener?.addButtonTapped(clip: videoCoverClip)
            })
            .store(in: &self.cancellables)

        self.bindKeyboard()
    }
}

extension CoverClipCreationViewController {
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
        textField.returnKeyType = .done
        textField.delegate = self
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
        self.updateTextField(textField, text: placeholder)
        return view
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.updateTextField(textField, text: text)
    }

    private func updateTextField(_ textField: UITextField, text: String) {
        switch textField.tag {
        case 0:
            self.previewTitleLabel.attributedText = self.makePreviewAttributedText(
                text,
                fontRepresent: self.selectedFont,
                size: Preview.Title.size,
                weight: Preview.Title.weight
            )
        case 1:
            self.previewDescriptionLabel.attributedText = self.makePreviewAttributedText(
                text,
                fontRepresent: self.selectedFont,
                size: Preview.Description.size,
                weight: Preview.Description.weight
            )
        default: break
        }
    }

    private func representForFont(index: Int) -> FontRepresentable {
        guard let represent = CustomFont.allCases[safe: index - 1] else {
            return UIFont.systemFont(ofSize: 12)
        }
        return represent
    }

    private func updateTextField(represent: FontRepresentable) {
        if let title = previewTitleLabel.attributedText?.string {
            self.previewTitleLabel.attributedText = self.makePreviewAttributedText(
                title,
                fontRepresent: represent,
                size: Preview.Title.size,
                weight: Preview.Title.weight
            )
        }

        if let description = previewDescriptionLabel.attributedText?.string {
            self.previewDescriptionLabel.attributedText = self.makePreviewAttributedText(
                description,
                fontRepresent: represent,
                size: Preview.Description.size,
                weight: Preview.Description.weight
            )
        }
    }

    private func makePreviewAttributedText(
        _ text: String,
        fontRepresent: FontRepresentable,
        size: CGFloat,
        weight: UIFont.Weight
    ) -> NSAttributedString {
        .makeAttributedString(
            text: text,
            font: fontRepresent.font(of: size, weight: weight),
            textColor: .white,
            letterSpacingPercentage: -0.43,
            alignment: .center
        )
    }
}

extension CoverClipCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        CustomFont.allCases.count + 1
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FontCell.reuseIdentifier, for: indexPath) as? FontCell else {
            return .init()
        }
        cell.drawCell(represent: self.representForFont(index: indexPath.item))
        return cell
    }
}

extension CoverClipCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedFont = self.representForFont(index: indexPath.item)
    }
}

extension CoverClipCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
