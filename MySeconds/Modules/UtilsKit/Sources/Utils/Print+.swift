//
//  Print+.swift
//  UtilsKit
//
//  Created by JeongHwan Lee on 1/26/25.
//

import Foundation

public func printDebug(
    _ message: Any,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[DEBUG] fileName: \(fileName) ::: line: \(line) ::: func: \(function) -> \(message)")
    #endif
}
