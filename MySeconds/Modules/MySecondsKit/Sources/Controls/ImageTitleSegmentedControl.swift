//
//  ImageTitleSegmentedControl.swift
//  MySecondsKit
//
//  Created by 이정환 on 5/5/25.
//

import Combine
import UIKit

import SnapKit

import ResourceKit
import UtilsKit

public final class ImageTitleSegmentedControl: UIControl {
    public var cancellables = Set<AnyCancellable>()

    private enum Constants {
        static let height: CGFloat = 36
        static let indicatorRadious: CGFloat = 16
        static let segmentedControlRadious: CGFloat = 18
    }

    public struct Item {
        public let image: UIImage
        public let title: String
        public init(image: UIImage, title: String) {
            self.image = image
            self.title = title
        }
    }

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 0
        return view
    }()

    private let indicatorView: UIView = {
        let view: UIView = .init()
        view.layer.cornerRadius = Constants.indicatorRadious
        view.layer.masksToBounds = true
        return view
    }()

    public private(set) var selectedIndex: Int = 0
    private var buttons: [UIButton] = []
    private var indicatorLeading: Constraint?
    private var indicatorWidth: Constraint?

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    public required init?(coder: NSCoder) { nil }

    override public func layoutSubviews() {
        super.layoutSubviews()

        invalidateIntrinsicContentSize()
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(width: self.buttons.map(\.intrinsicContentSize.width).reduce(0, +), height: Constants.height)
    }

    private func setupUI() {
        layer.cornerRadius = Constants.segmentedControlRadious
        layer.masksToBounds = true

        self.snp.makeConstraints {
            $0.height.equalTo(Constants.height)
        }

        addSubviews(self.indicatorView, self.stackView)
        self.indicatorView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(2)
            self.indicatorLeading = $0.leading.equalToSuperview().constraint
            self.indicatorWidth = $0.width.equalTo(0).constraint
        }
        self.stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    public func configure(
        items: [Item],
        indicatorColor: UIColor = .white,
        buttonTintColor: UIColor = .neutral600,
        backgroundColor: UIColor = .neutral100,
        initialIndex: Int = 0
    ) {
        self.backgroundColor = backgroundColor

        self.buttons.forEach { $0.removeFromSuperview() }
        self.buttons.removeAll()

        if initialIndex < items.count {
            self.selectedIndex = initialIndex
        }

        for (idx, item) in items.enumerated() {
            let button = self.makeSegmentButton(item: item, tintColor: buttonTintColor)
            button.tag = idx
            button.publisher(for: .touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    guard let self,
                          button.tag != self.selectedIndex else { return }
                    self.selectedIndex = idx
                    self.updateIndicator(animated: true)
                })
                .store(in: &self.cancellables)

            self.stackView.addArrangedSubview(button)
            self.buttons.append(button)
            button.snp.makeConstraints {
                $0.width.equalTo(button.intrinsicContentSize.width)
            }
        }

        self.indicatorView.backgroundColor = indicatorColor
        self.indicatorView.applyShadow(color: .black.withAlphaComponent(0.1), y: 1, blur: 4)
        layoutIfNeeded()
        self.updateIndicator(animated: false)
    }

    private func makeSegmentButton(item: Item, tintColor: UIColor) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = item.image.resized(to: .init(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)
        config.attributedTitle = .init(
            .makeAttributedString(
                text: item.title,
                font: .systemFont(ofSize: 12, weight: .regular),
                textColor: tintColor
            )
        )
        config.imagePadding = 4
        config.contentInsets = .init(top: 6, leading: 16, bottom: 6, trailing: 16)
        let button = UIButton(configuration: config)
        button.tintColor = tintColor
        return button
    }

    private func updateIndicator(animated: Bool) {
        guard let button = self.buttons[safe: self.selectedIndex],
              let leading = self.indicatorLeading, let width = self.indicatorWidth
        else { return }
        let newX = button.frame.minX + 2
        let newW = button.frame.width - 4

        leading.update(offset: newX)
        width.update(offset: newW)
        if animated {
            UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
        } else {
            self.layoutIfNeeded()
        }
    }
}
