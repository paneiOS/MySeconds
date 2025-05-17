//
//  CoverClip.swift
//  CoverClipCreation
//
//  Created by 이정환 on 5/16/25.
//

import Foundation

public struct CoverClip {
    public enum Position: String {
        case intro = "인트로"
        case outro = "아웃트로"
    }

    var position: Position
    var title: String
    var description: String
//    var font: String

    public init(position: Position, title: String, description: String) {
        self.position = position
        self.title = title
        self.description = description
    }
}
