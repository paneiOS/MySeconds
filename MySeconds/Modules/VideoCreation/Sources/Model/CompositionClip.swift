//
//  CompositionClip.swift
//  VideoCreation
//
//  Created by 이정환 on 5/2/25.
//

import Foundation

public enum CompositionClip: Hashable {
    case cover(StaticClip)
    case video(VideoClip)
}
