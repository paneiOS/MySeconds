//
//  VideoRecordingProtocol.swift
//  VideoRecordingManager
//
//  Created by Chung Wussup on 6/25/25.
//

import AVFoundation
import Combine
import Foundation
import UIKit

public protocol VideoRecordingManagerProtocol: AnyObject {
    var previewLayer: AVCaptureVideoPreviewLayer? { get }

    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    var recordedURLPublisher: AnyPublisher<URL, Never> { get }

    var aspectRatioTextPublisher: AnyPublisher<String, Never> { get }
    var durationTextPublisher: AnyPublisher<Int, Never> { get }

    func requestAuthorizationPublisher() -> AnyPublisher<Bool, Never>
    func configurePreview(in view: UIView, cornerRadius: CGFloat)
    func updatePreviewLayout()

    func startSession()
    func stopSession()

    func toggleRecording()
    func switchCamera()
    func changeAspectRatio()
    func changeDuration()

    func duration(isRecording: Bool) -> Int
}
