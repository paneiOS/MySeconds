//
//  Videos.swift
//  ResourceKit
//
//  Created by JeongHwan Lee on 1/27/25.
//

import AVFoundation

public extension AVPlayer {
    static var sampleVideo: AVPlayer {
        guard let url = Bundle.module.url(forResource: "sample", withExtension: "mp4") else {
            return .init()
        }
        return .init(url: url)
    }
}
