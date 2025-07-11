//
//  RecordingOptions.swift
//  VideoRecord
//
//  Created by 이정환 on 7/9/25.
//

import Foundation

public struct RecordingOptions {
    public let coverClipsCount: Int
    public let maxVideoClipsCount: Int
    public let recordDurations: [TimeInterval]
    public let ratioTypes: [RatioType]

    public init(coverClipsCount: Int, maxVideoClipsCount: Int, recordDurations: [TimeInterval], ratioTypes: [RatioType]) {
        self.coverClipsCount = coverClipsCount
        self.maxVideoClipsCount = maxVideoClipsCount
        self.recordDurations = recordDurations
        self.ratioTypes = ratioTypes
    }
}
