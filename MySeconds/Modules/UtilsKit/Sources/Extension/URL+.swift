//
//  URL+.swift
//  UtilsKit
//
//  Created by Chung Wussup on 6/18/25.
//

import AVFoundation
import UIKit

public extension URL {
    func videoDuration() async throws -> Double {
        let asset = AVAsset(url: self)
        let duration = try await asset.load(.duration)
        return CMTimeGetSeconds(duration)
    }
    
    func generateThumbnail(at seconds: TimeInterval = 0.1) -> UIImage? {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(
                at: CMTime(seconds: seconds, preferredTimescale: 600),
                actualTime: nil
            )
            return UIImage(cgImage: cgImage)
        } catch {
            print("썸네일 생성 실패:", error)
            return nil
        }
    }
}
