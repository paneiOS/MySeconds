//
//  RatioType.swift
//  SharedModels
//
//  Created by 이정환 on 7/8/25.
//

import Foundation

public enum RatioType: String {
    case oneToOne = "1:1"
    case threeToFour = "3:4"

    public var ratio: CGFloat {
        switch self {
        case .oneToOne:
            1.0
        case .threeToFour:
            4.0 / 3.0
        }
    }
}
