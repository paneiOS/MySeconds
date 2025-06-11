//
//  CompositionClip.swift
//  SharedModels
//
//  Created by 이정환 on 6/12/25.
//

import Foundation

public enum CompositionClip: Hashable {
    case cover(VideoCoverClip)
    case video(VideoClip)
}
