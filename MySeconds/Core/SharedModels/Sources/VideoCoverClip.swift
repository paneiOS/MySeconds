//
//  VideoCoverClip.swift
//  VideoCreation
//
//  Created by 이정환 on 5/2/25.
//

import UIKit

public struct VideoCoverClip: Hashable {
    public let id: UUID
    public var title: NSAttributedString?
    public var description: NSAttributedString?
    public var date: Date?
    public var duration: TimeInterval
    public var thumbnail: UIImage?
    public var type: CoverType

    public enum CoverType: String {
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
}
