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

    func asyncCompactMap<T>(_ transform: @escaping (Element) async -> T?) async -> [T] {
        var results = [T]()
        for element in self {
            if let value = await transform(element) {
                results.append(value)
            }
        }
        return results
    }
}
