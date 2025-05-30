//
//  Date+.swift
//  UtilsKit
//
//  Created by 이정환 on 4/29/25.
//

import Foundation

public extension Date {
    var dateToString: String {
        DateFormatter.dateToString.string(from: self)
    }
}

private extension DateFormatter {
    static let dateToString: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
