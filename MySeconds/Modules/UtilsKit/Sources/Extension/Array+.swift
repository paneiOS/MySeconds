//
//  Array+.swift
//  UtilsKit
//
//  Created by 이정환 on 4/25/25.
//

import Foundation

public extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
