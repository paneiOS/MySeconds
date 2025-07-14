//
//  CompositionClip.swift
//  SharedModels
//
//  Created by 이정환 on 6/12/25.
//

import Foundation

public enum CompositionClip: Codable, Hashable {
    case cover(VideoCoverClip)
    case video(VideoClip)
}

public extension CompositionClip {
    static func isIntro(_ clip: CompositionClip) -> Bool {
        if case let .cover(meta) = clip {
            return meta.type == .intro
        }
        return false
    }

    static func isOutro(_ clip: CompositionClip) -> Bool {
        if case let .cover(meta) = clip {
            return meta.type == .outro
        }
        return false
    }
}
