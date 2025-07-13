//
//  SelectButtonsView.swift
//  ComponentsKit
//
//  Created by 이정환 on 4/24/25.
//

import Combine
import UIKit

import SnapKit

import ResourceKit
import UtilsKit

public struct GridSize {
    let row: Int
    let column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

open class SelectButtonsView: UIView {
    private var cancellables = Set<AnyCancellable>()

    private let mainStackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()

    @Published public private(set) var selectedValue: String?
    private var selectedButton: DSButton? {
        didSet {
            self.selectedValue = self.selectedButton?.currentTitle
        }
    }

    public var selectionPublisher: AnyPublisher<String?, Never> {
        self.$selectedValue.eraseToAnyPublisher()
    }

    public init(
        buttonTitles: [String],
        gridSize: GridSize,
        configuration: ButtonStyleConfiguration = .init(),
        selectedIndex: Int? = nil
    ) {
        super.init(frame: .zero)

        self.setupUI()
        self.createGridButtons(from: buttonTitles, gridSize: gridSize, config: configuration, selectedIndex: selectedIndex)
            .forEach { [weak self] rowButtons in
                guard let self else { return }
                let rowStackView = self.createRowStackView(buttons: rowButtons)
                self.mainStackView.addArrangedSubview(rowStackView)
            }
        if let selectedIndex {
            self.selectedValue = buttonTitles[safe: selectedIndex]
        }
    }

    public required init?(coder _: NSCoder) { nil }

    private func setupUI() {
        self.addSubview(self.mainStackView)
        self.mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func createGridButtons(from titles: [String], gridSize: GridSize, config: ButtonStyleConfiguration, selectedIndex: Int?) -> [[DSButton]] {
        return stride(from: 0, to: titles.count, by: gridSize.column)
            .map { startIndex in
                (startIndex ..< min(startIndex + gridSize.column, titles.count))
                    .compactMap { titles[safe: $0] }
                    .enumerated()
                    .map { index, title in
                        let isSelected = (selectedIndex == startIndex + index)
                        return createButton(title: title, config: config, isSelected: isSelected)
                    }
            }

        func createButton(title: String, config: ButtonStyleConfiguration, isSelected: Bool) -> DSButton {
            let button = DSButton(styleConfiguration: config)
            button.setTitle(title, for: .normal)
            button.layer.borderColor = UIColor.neutral200.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            button.isSelected = isSelected
            button.publisher(for: .touchUpInside)
                .filter { [weak self] _ in
                    guard let self else { return false }
                    return button !== self.selectedButton
                }
                .sink(receiveValue: { [weak self] _ in
                    guard let self else { return }
                    self.selectedButton?.isSelected = false
                    button.isSelected = true
                    self.selectedButton = button
                })
                .store(in: &self.cancellables)
            return button
        }
    }

    private func createRowStackView(buttons: [DSButton]) -> UIStackView {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.spacing = 10
        rowStackView.distribution = .fillEqually
        for button in buttons {
            rowStackView.addArrangedSubview(button)
        }
        return rowStackView
    }
}
