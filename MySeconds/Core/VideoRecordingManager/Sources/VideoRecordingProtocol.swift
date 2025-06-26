//
//  VideoRecordingProtocol.swift
//  VideoRecordingManager
//
//  Created by Chung Wussup on 6/25/25.
//

import AVFoundation
import Combine
import Foundation

public protocol VideoRecordingManagerProtocol: AnyObject {
    func requestAuthorization(aspectRatio: AspectRatio) async -> Bool
    func makePreviewLayer(cornerRadius: CGFloat) -> AVCaptureVideoPreviewLayer
    func updateAspectRatio(aspectRatio: AspectRatio)
    func recordVideo(duration: TimeInterval) async throws -> URL
    func cancelRecording()

    func startSession()
    func stopSession()
    func switchCamera()
}
