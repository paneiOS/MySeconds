//
//  VideoDraft.swift
//  VideoDraftStorage
//
//  Created by 이정환 on 6/5/25.
//

import Foundation

import UtilsKit

public struct VideoDraft: Codable, Equatable {
    public let id: UUID
    public let createdAt: Date
    public let duration: Double
    public let thumbnailImageData: Data
    public let videoData: Data

    public init(
        id: UUID = .init(),
        createdAt: Date = .init(),
        duration: Double,
        thumbnailImageData: Data,
        videoData: Data
    ) {
        self.id = id
        self.createdAt = createdAt
        self.duration = duration
        self.thumbnailImageData = thumbnailImageData
        self.videoData = videoData
    }

    var createdAtStr: String {
        self.createdAt.formattedString(format: "yyyyMMdd_HHmmssSSS")
    }
}
