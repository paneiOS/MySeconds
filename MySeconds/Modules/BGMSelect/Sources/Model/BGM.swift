//
//  BGM.swift
//  BGMSelect
//
//  Created by 이정환 on 5/30/25.
//

import Foundation

public struct BGM {
    public let fileName: String
    public let bpm: Int
    public let duratuion: TimeInterval
    public let category: String

    var bpmStr: String {
        "\(self.bpm)bpm"
    }

    var durationStr: String {
        self.duratuion.formattedTime
    }
}
