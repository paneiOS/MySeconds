//
//  CoverClip.swift
//  VideoCreation
//
//  Created by 이정환 on 5/2/25.
//

import UIKit

public struct CoverClip: Hashable {
    public let id: UUID
    public var title: String?
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
        title: String?,
        date: Date?,
        duration: TimeInterval = 1.0,
        thumbnail: UIImage? = nil,
        type: CoverType
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.duration = duration
        self.thumbnail = thumbnail
        self.type = type
    }
}
