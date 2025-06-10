//
//  CompositionClip.swift
//  VideoCreation
//
//  Created by 이정환 on 5/2/25.
//

import Foundation
import SharedModels

public enum CompositionClip: Hashable {
    case cover(VideoCoverClip)
    case video(VideoClip)
}
