//
//  TimeInterval+.swift
//  UtilsKit
//
//  Created by 이정환 on 6/4/25.
//

import Foundation

public extension TimeInterval {
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
