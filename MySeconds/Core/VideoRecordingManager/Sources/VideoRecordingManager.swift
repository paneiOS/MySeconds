//
//  VideoRecordingManager.swift
//  MySeconds
//
//  Created by chungwussup on 06/25/2025.
//

import AVFoundation

public enum AspectRatio: String, CaseIterable {
    case oneToOne = "1:1"
    case fourToThree = "4:3"

    public var ratio: CGFloat {
        switch self {
        case .oneToOne:
            1.0
        case .fourToThree:
            4.0 / 3.0
        }
    }
}

public enum CameraError: Error {
    case noDevice
    case unableToAddInput
    case sessionConfigurationFailed
    case alreadyRecording
    case cancelled
}

public final class VideoRecordingManager: NSObject, VideoRecordingManagerProtocol {
    public private(set) var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let movieOutput = AVCaptureMovieFileOutput()

    private var recordingContinuation: CheckedContinuation<URL, Error>?
    private var recordingTimer: Timer?
    private var isUserCancelled: Bool = false

    deinit {
        recordingTimer?.invalidate()
    }

    private func configureSession(aspectRatio: AspectRatio) -> Result<Void, CameraError> {
        self.session.beginConfiguration()
        self.session.sessionPreset = .high

        if let input = self.videoDeviceInput {
            self.session.removeInput(input)
        }

        // input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            self.session.commitConfiguration()
            return .failure(.noDevice)
        }

        guard let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            self.session.commitConfiguration()
            return .failure(.unableToAddInput)
        }

        self.session.addInput(input)
        self.videoDeviceInput = input

        // output
        if self.session.canAddOutput(self.movieOutput) {
            self.session.addOutput(self.movieOutput)
        }

        self.session.commitConfiguration()
        return .success(())
    }

    public func requestAuthorization(aspectRatio: AspectRatio) async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            switch self.configureSession(aspectRatio: aspectRatio) {
            case .success:
                return true
            case .failure:
                return false
            }

        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }

            if granted {
                switch self.configureSession(aspectRatio: aspectRatio) {
                case .success:
                    return true
                case .failure:
                    return false
                }
            } else {
                return false
            }

        default:
            return false
        }
    }

    public func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    public func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    public func switchCamera() {
        guard let currentInput = self.videoDeviceInput else { return }

        let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back

        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }

        self.session.beginConfiguration()
        self.session.removeInput(currentInput)

        if self.session.canAddInput(newInput) {
            self.session.addInput(newInput)
            self.videoDeviceInput = newInput
        } else {
            self.session.addInput(currentInput)
        }

        self.session.commitConfiguration()
    }

    public func recordVideo(duration: TimeInterval) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            guard self.session.isRunning else {
                continuation.resume(throwing: CameraError.sessionConfigurationFailed)
                return
            }

            guard !self.movieOutput.isRecording else {
                continuation.resume(throwing: CameraError.alreadyRecording)
                return
            }

            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")

            self.isUserCancelled = false
            self.recordingContinuation = continuation
            self.movieOutput.startRecording(to: outputURL, recordingDelegate: self)

            // 타이머로 녹화종료
            self.recordingTimer = Timer(timeInterval: duration, repeats: false) { [weak self] _ in
                guard let self else { return }
                self.movieOutput.stopRecording()
            }

            if let timer = self.recordingTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }

    public func cancelRecording() {
        guard self.movieOutput.isRecording else { return }
        self.isUserCancelled = true
        self.movieOutput.stopRecording()
    }
}

extension VideoRecordingManager: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        self.recordingTimer?.invalidate()

        // recordVideo() 내부 continuation에 결과(url) 전달
        guard let continuation = self.recordingContinuation else { return }
        self.recordingContinuation = nil

        if let error {
            continuation.resume(throwing: error)
        } else if self.isUserCancelled {
            continuation.resume(throwing: CameraError.cancelled)
        } else {
            continuation.resume(returning: outputFileURL)
        }
    }
}
