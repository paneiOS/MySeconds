//
//  VideoCoverClip.swift
//  VideoCreation
//
//  Created by 이정환 on 5/2/25.
//

import UIKit

public struct VideoCoverClip: Clip {
    public let id: UUID
    public var title: NSAttributedString?
    public var description: NSAttributedString?
    public var date: Date?
    public var duration: TimeInterval
    public var thumbnail: UIImage?
    public var type: CoverType

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case duration
        case type
    }

    public enum CoverType: String, Codable {
        case intro = "인트로"
        case outro = "아웃트로"
    }

    public init(
        id: UUID = .init(),
        title: NSAttributedString?,
        description: NSAttributedString?,
        date: Date? = .init(),
        duration: TimeInterval = 1.0,
        thumbnail: UIImage? = nil,
        type: CoverType
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.duration = duration
        self.thumbnail = thumbnail
        self.type = type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let date = try container.decodeIfPresent(Date.self, forKey: .date)
        let duration = try container.decode(TimeInterval.self, forKey: .duration)
        let type = try container.decode(CoverType.self, forKey: .type)
        self.init(
            id: id,
            title: nil,
            description: nil,
            date: date,
            duration: duration,
            thumbnail: nil,
            type: type
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.date, forKey: .date)
        try container.encode(self.duration, forKey: .duration)
        try container.encode(self.type, forKey: .type)
    }
}
