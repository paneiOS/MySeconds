//
//  StaticClip.swift
//  VideoCreation
//
//  Created by 이정환 on 5/2/25.
//

import UIKit

public struct StaticClip: Hashable {
    public let id: UUID
    public var title: String?
    public var date: Date?
    public var duration: TimeInterval
    public var thumbnail: UIImage?
    public var type: `Type`

    public enum `Type` {
        case intro
        case outro
    }

    public init(
        id: UUID = .init(),
        title: String?,
        date: Date?,
        duration: TimeInterval = 1.0,
        thumbnail: UIImage? = nil,
        type: Type
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.duration = duration
        self.thumbnail = thumbnail
        self.type = type
    }
}
