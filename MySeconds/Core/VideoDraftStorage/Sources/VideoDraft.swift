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
    public let thumbnail: Data

    public init(
        id: UUID = .init(),
        createdAt: Date = .init(),
        duration: Double,
        thumbnail: Data,
    ) {
        self.id = id
        self.createdAt = createdAt
        self.duration = duration
        self.thumbnail = thumbnail
    }

    public var fileBaseName: String {
        self.createdAt.formattedString(format: "yyyyMMdd_HHmmssSSS") + "_" + self.id.uuidString
    }
}
