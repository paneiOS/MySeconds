//
//  VideoRecordingManager.swift
//  MySeconds
//
//  Created by chungwussup on 06/25/2025.
//

import AVFoundation
import Combine

public enum AspectRatio: String, CaseIterable {
    case oneToOne = "1:1"
    case fourToThree = "4:3"

    public mutating func toggle() {
        self = (self == .oneToOne) ? .fourToThree : .oneToOne
    }

    var preset: AVCaptureSession.Preset {
        switch self {
        case .oneToOne: .high
        case .fourToThree: .vga640x480
        }
    }
}

public final class VideoRecordingManager: NSObject, VideoRecordingManagerProtocol {
    public enum CameraError: Error {
        case authorizationDenied
        case noDevice
        case unableToAddInput
        case sessionConfigurationFailed
        case unknown
    }

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    public var isRecordingPublisher: AnyPublisher<Bool, Never> {
        self.isRecordingSubject.eraseToAnyPublisher()
    }

    private let recordedURLSubject = PassthroughSubject<URL, Never>()
    public var recordedURLPublisher: AnyPublisher<URL, Never> {
        self.recordedURLSubject.eraseToAnyPublisher()
    }

    private let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let movieOutput = AVCaptureMovieFileOutput()

    private var isFrontCamera = false
    private var recordingTimer: Timer?
    private var isUserCancelled: Bool = false

    override public init() {
        super.init()
    }

    deinit {
        recordingTimer?.invalidate()
    }

    public func configureSession(aspectRatio: AspectRatio) -> Result<Void, CameraError> {
        self.session.beginConfiguration()
        self.session.sessionPreset = aspectRatio.preset

        // Input
        if let currentInput = videoDeviceInput {
            self.session.removeInput(currentInput)
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            self.session.commitConfiguration()
            return .failure(.noDevice)
        }

        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            self.session.commitConfiguration()
            return .failure(.unableToAddInput)
        }

        self.session.addInput(input)
        self.videoDeviceInput = input

        // Output
        if self.session.canAddOutput(self.movieOutput) {
            self.session.addOutput(self.movieOutput)
        }

        self.session.commitConfiguration()
        return .success(())
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

    public func requestAuthorizationPublisher(aspectRatio: AspectRatio) -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { [weak self] promise in
            guard let self else {
                promise(.success(false))
                return
            }

            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                switch self.configureSession(aspectRatio: aspectRatio) {
                case .success:
                    promise(.success(true))
                case .failure:
                    promise(.success(false))
                }

            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        switch self.configureSession(aspectRatio: aspectRatio) {
                        case .success:
                            promise(.success(true))
                        case .failure:
                            promise(.success(false))
                        }
                    } else {
                        promise(.success(false))
                    }
                }

            default:
                promise(.success(false))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Preview

    public func makePreviewLayer(cornerRadius: CGFloat = 0) -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        return layer
    }

    // MARK: - 버튼

    public func toggleRecording(duration: TimeInterval) {
        guard self.session.isRunning else { return }

        if self.movieOutput.isRecording {
            self.isUserCancelled = true
            self.movieOutput.stopRecording()
            self.isRecordingSubject.send(false)
            self.recordingTimer?.invalidate()
        } else {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            self.isUserCancelled = false
            self.movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            self.isRecordingSubject.send(true)

            self.recordingTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                guard let self else { return }
                self.movieOutput.stopRecording()
            }
        }
    }

    public func switchCamera() {
        guard let currentInput = videoDeviceInput else { return }

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

    public func updateAspectRatio(aspectRatio: AspectRatio) {
        self.session.beginConfiguration()
        self.session.sessionPreset = aspectRatio.preset
        self.session.commitConfiguration()
    }
}

extension VideoRecordingManager: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        self.isRecordingSubject.send(false)

        guard error == nil else {
            print("녹화 실패:", error!)
            return
        }

        guard self.isUserCancelled == false else {
            print("녹화 취소")
            return
        }

        self.recordedURLSubject.send(outputFileURL)
    }
}
