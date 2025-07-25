//
//  DSButton.swift
//  ComponentsKit
//
//  Created by 이정환 on 4/29/25.
//

import UIKit

import ResourceKit

public final class DSButton: UIButton {
    let styleConfiguration: ButtonStyleConfiguration

    override public var isEnabled: Bool {
        didSet {
            self.updateAppearance()
        }
    }

    override public var isSelected: Bool {
        didSet {
            self.updateAppearance()
        }
    }

    public init(styleConfiguration: ButtonStyleConfiguration = .init()) {
        self.styleConfiguration = styleConfiguration
        super.init(frame: .zero)

        self.setupUI()
    }

    required init?(coder _: NSCoder) { nil }

    private func setupUI() {
        tintColor = .white
        self.setTitleColor(self.styleConfiguration.activeTextColor, for: .selected)
        self.setTitleColor(self.styleConfiguration.activeTextColor, for: [.selected, .highlighted])
        self.setTitleColor(self.styleConfiguration.inactiveTextColor, for: [.normal])
        self.setTitleColor(self.styleConfiguration.inactiveTextColor, for: .disabled)
    }

    private func updateAppearance() {
        if self.isEnabled {
            backgroundColor = self.isSelected ? self.styleConfiguration.activeBGColor : self.styleConfiguration.inactiveBGColor
        } else {
            backgroundColor = self.styleConfiguration.disableBGColor
        }
    }
}
