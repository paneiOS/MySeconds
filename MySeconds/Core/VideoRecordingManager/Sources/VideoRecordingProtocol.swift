//
//  VideoRecordingProtocol.swift
//  VideoRecordingManager
//
//  Created by Chung Wussup on 6/25/25.
//

import AVFoundation
import Combine
import Foundation

import SharedModels

public protocol VideoRecordingManagerProtocol: AnyObject {
    var session: AVCaptureSession { get }

    func requestAuthorization(ratioType: RatioType) async -> Bool
    func recordVideo(duration: TimeInterval) async throws -> URL
    func cancelRecording()

    func startSession()
    func stopSession()
    func switchCamera()
}
