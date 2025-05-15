//
//  ButtonStyleConfiguration.swift
//  MySecondsKit
//
//  Created by 이정환 on 5/1/25.
//

import UIKit

import ResourceKit

public struct ButtonStyleConfiguration {
    let activeBGColor: UIColor
    let activeTextColor: UIColor
    let inactiveBGColor: UIColor
    let inactiveTextColor: UIColor
    let disableBGColor: UIColor
    let disableTextColor: UIColor

    public init(
        activeBGColor: UIColor = .neutral800,
        activeTextColor: UIColor = .white,
        inactiveBGColor: UIColor = .white,
        inactiveTextColor: UIColor = .neutral800,
        disableBGColor: UIColor = .neutral400,
        disableTextColor: UIColor = .white
    ) {
        self.activeBGColor = activeBGColor
        self.activeTextColor = activeTextColor
        self.inactiveBGColor = inactiveBGColor
        self.inactiveTextColor = inactiveTextColor
        self.disableBGColor = disableBGColor
        self.disableTextColor = disableTextColor
    }
}
