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
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    var recordedURLPublisher: AnyPublisher<URL, Never> { get }
    var aspectRatioTextPublisher: AnyPublisher<String, Never> { get }
    func requestAuthorizationPublisher() -> AnyPublisher<Bool, Never>
    func makePreviewLayer(cornerRadius: CGFloat) -> AVCaptureVideoPreviewLayer
    
    func toggleRecording(duration: TimeInterval)
    
    func startSession()
    func stopSession()
    
    func switchCamera()
    func changeAspectRatio()
}
