//
//  Deinitializable.swift
//  UtilsKit
//
//  Created by 이정환 on 1/30/25.
//

import Foundation

public protocol Deinitializable {}

public extension Deinitializable {
    func printDeinit() {
        #if DEBUG
            print("✅ Deinit: \(String(describing: type(of: self)))")
        #endif
    }
}
