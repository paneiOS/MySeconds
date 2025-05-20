//
//  CameraManager.swift
//  VideoRecord
//
//  Created by Chung Wussup on 5/20/25.
//

import AVFoundation
import UIKit

enum CameraError: Error {
    case authorizationDenied
    case noDevice
    case unableToAddInput
}

protocol CameraManagerDelegate: AnyObject {
    func cameraService(_ service: CameraManagerProtocol, didStartRecording url: URL)
    func cameraService(_ service: CameraManagerProtocol, didFinishRecording url: URL, error: Error?)
    func cameraServiceDidFailAuthorization(_ service: CameraManagerProtocol)
}

protocol CameraManagerProtocol: AnyObject {
    var delegate: CameraManagerDelegate? { get set }
    var isAuthorized: Bool { get }
    func previewConfigure(in view: UIView, cornerRadius: CGFloat)
    func requestAuthorizationAndStart()
    func toggleRecording()
    func toggleAspectRatio()
    func toggleDuration()
    func switchCamera()
    func updatePreviewLayout()
    var currentAspectRatioText: String { get }
    var recordingDurationText: String { get }
    var isRecording: Bool { get }
}

final class CameraManager: NSObject, CameraManagerProtocol {
    enum AspectRatio: String, CaseIterable {
        case oneToOne = "1:1"
        case fourToThree = "4:3"
        mutating func toggle() {
            self = (self == .oneToOne) ? .fourToThree : .oneToOne
        }
    }

    weak var delegate: CameraManagerDelegate?
    private(set) var isAuthorized = false

    var currentAspectRatioText: String { self.aspectRatio.rawValue }
    var recordingDurationText: String { "\(Int(self.maxRecordingTime))초" }
    var isRecording: Bool { self.movieOutput.isRecording }

    private var aspectRatio: AspectRatio = .oneToOne
    private var maxRecordingTime: TimeInterval = 3

    private let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var previewContainer: UIView?
    private var recordingTask: Task<Void, Never>?

    func previewConfigure(in view: UIView, cornerRadius: CGFloat) {
        self.previewContainer = view
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        view.layer.addSublayer(layer)
        self.previewLayer = layer
    }

    func requestAuthorizationAndStart() {
        Task {
            do {
                try await checkPermission()
                self.isAuthorized = true
                try await startSession()

                Task.detached { [weak self] in
                    guard let self else { return }
                    self.session.startRunning()
                }
            } catch {
                await MainActor.run {
                    self.delegate?.cameraServiceDidFailAuthorization(self)
                }
            }
        }
    }

    func toggleRecording() {
        guard self.isAuthorized else { return }

        if self.movieOutput.isRecording {
            self.movieOutput.stopRecording()
            self.recordingTask?.cancel()
        } else {
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")

            self.movieOutput.startRecording(to: fileURL, recordingDelegate: self)

            self.recordingTask?.cancel()
            self.recordingTask = Task { [weak self] in
                guard let self else { return }
                let duration = UInt64(self.maxRecordingTime * 1_000_000_000)

                do {
                    try await Task.sleep(nanoseconds: duration)
                } catch {
                    return
                }

                await MainActor.run {
                    self.movieOutput.stopRecording()
                }
            }
        }
    }

    func toggleAspectRatio() {
        guard self.isAuthorized else { return }
        self.aspectRatio.toggle()
        self.updatePreviewLayout()
    }

    func toggleDuration() {
        guard self.isAuthorized else { return }
        let options: [TimeInterval] = [3, 4, 5]

        if let currentIndex = options.firstIndex(of: maxRecordingTime) {
            let nextIndex = (currentIndex + 1) % options.count
            self.maxRecordingTime = options[nextIndex]
        } else {
            self.maxRecordingTime = options.first ?? 3
        }
    }

    func switchCamera() {
        guard self.isAuthorized,
              let currentInput = session.inputs.first as? AVCaptureDeviceInput
        else { return }

        let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back

        do {
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
            let newInput = try AVCaptureDeviceInput(device: newDevice)

            self.session.beginConfiguration()
            self.session.removeInput(currentInput)
            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
            } else {
                self.session.addInput(currentInput)
            }
            self.session.commitConfiguration()
        } catch {
            print("Camera switch failed:", error)
        }
    }

    func updatePreviewLayout() {
        guard let container = previewContainer,
              let layer = previewLayer
        else { return }

        let width = container.bounds.width
        let height = (aspectRatio == .oneToOne) ? width : width * 4 / 3
        layer.frame = CGRect(
            x: 0,
            y: (container.bounds.height - height) / 2,
            width: width,
            height: height
        )
    }
}

private extension CameraManager {
    func checkPermission() async throws {
        try await withCheckedThrowingContinuation { cont in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    cont.resume()
                } else {
                    cont.resume(throwing: CameraError.authorizationDenied)
                }
            }
        }
    }

    func startSession() async throws {
        try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.beginConfiguration()
                defer { self.session.commitConfiguration() }

                do {
                    guard let device = AVCaptureDevice.default(
                        .builtInWideAngleCamera,
                        for: .video,
                        position: .back
                    ) else {
                        throw CameraError.noDevice
                    }
                    let input = try AVCaptureDeviceInput(device: device)
                    guard self.session.canAddInput(input) else {
                        throw CameraError.unableToAddInput
                    }
                    self.session.addInput(input)

                    if self.session.canAddOutput(self.movieOutput) {
                        self.session.addOutput(self.movieOutput)
                    }
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo url: URL,
        from connections: [AVCaptureConnection]
    ) {
        self.delegate?.cameraService(self, didStartRecording: url)
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo url: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        self.delegate?.cameraService(self, didFinishRecording: url, error: error)
    }
}
