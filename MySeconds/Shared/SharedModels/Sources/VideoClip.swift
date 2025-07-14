//
//  VideoClip.swift
//  SharedModels
//
//  Created by 이정환 on 6/12/25.
//

import UIKit

public protocol Clip: Codable, Hashable {
    var id: UUID { get }
    var duration: TimeInterval { get }
    var thumbnailData: Data? { get }
}

public struct VideoClip: Clip {
    public let id: UUID
    public let createdAt: Date
    public let fileName: String
    public let duration: TimeInterval

    public var thumbnailData: Data?

    public var thumbnail: UIImage? {
        self.thumbnailData.flatMap { UIImage(data: $0) }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case fileName
        case duration
        case thumbnailData
    }

    public init(
        id: UUID,
        createdAt: Date,
        fileName: String,
        duration: TimeInterval,
        thumbnail: UIImage?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.fileName = fileName
        self.duration = duration
        self.thumbnailData = thumbnail?.jpegData(compressionQuality: 0.8)
    }

    public func filePath(directoryURL: URL) -> URL {
        directoryURL.appendingPathComponent(self.fileName + ".mp4")
    }
}
