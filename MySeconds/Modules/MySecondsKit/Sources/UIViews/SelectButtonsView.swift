//
//  SelectButtonsView.swift
//  MySecondsKit
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

public struct SelectButtonsConfiguration {
    let selectedColor: UIColor
    let selectedTextColor: UIColor
    let deSelectedColor: UIColor
    let deSelectedTextColor: UIColor

    public init(
        selectedColor: UIColor = .black,
        selectedTextColor: UIColor = .white,
        deSelectedColor: UIColor = .white,
        deSelectedTextColor: UIColor = .black
    ) {
        self.selectedColor = selectedColor
        self.selectedTextColor = selectedTextColor
        self.deSelectedColor = deSelectedColor
        self.deSelectedTextColor = deSelectedTextColor
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
    public var selectionPublisher: AnyPublisher<String?, Never> {
        self.$selectedValue.eraseToAnyPublisher()
    }

    public init(
        buttonTitles: [String],
        gridSize: GridSize,
        configuration: SelectButtonsConfiguration = .init(),
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

    private func createGridButtons(from titles: [String], gridSize: GridSize, config: SelectButtonsConfiguration, selectedIndex: Int?) -> [[UIButton]] {
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

        func createButton(title: String, config: SelectButtonsConfiguration, isSelected: Bool) -> UIButton {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(isSelected ? config.selectedTextColor : config.deSelectedTextColor, for: .normal)
            button.backgroundColor = isSelected ? config.selectedColor : config.deSelectedColor
            button.layer.borderColor = UIColor.neutral200.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            button.publisher(for: .touchUpInside)
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.selectedValue = title
                    for case let rowStack as UIStackView in self.mainStackView.arrangedSubviews {
                        for case let btn as UIButton in rowStack.arrangedSubviews {
                            let isSelected = btn.title(for: .normal) == self.selectedValue
                            button.isSelected = isSelected
                            btn.setTitleColor(isSelected ? config.selectedTextColor : config.deSelectedTextColor, for: .normal)
                            btn.backgroundColor = isSelected ? config.selectedColor : config.deSelectedColor
                        }
                    }
                }
                .store(in: &self.cancellables)
            return button
        }
    }

    private func createRowStackView(buttons: [UIButton]) -> UIStackView {
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
