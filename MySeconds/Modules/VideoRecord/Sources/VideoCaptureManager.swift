//
//  VideoCaptureManager.swift
//  VideoRecord
//
//  Created by Chung Wussup on 6/16/25.
//

import AVFoundation
import Combine
import UIKit

public enum CameraError: Error {
    case authorizationDenied
    case noDevice
    case unableToAddInput
    case sessionConfigurationFailed
    case unknown
}

public protocol CameraManagerProtocol: AnyObject {
    var previewLayer: AVCaptureVideoPreviewLayer? { get }

    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    var recordedURLPublisher: AnyPublisher<URL, Never> { get }

    var aspectRatioTextPublisher: AnyPublisher<String, Never> { get }
    var durationTextPublisher: AnyPublisher<String, Never> { get }
    var authorizationPublisher: AnyPublisher<Bool, Never> { get }

    func requestAuthorization()
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

public final class CameraManager: NSObject, CameraManagerProtocol {
    private enum AspectRatio: String, CaseIterable {
        case oneToOne = "1:1"
        case fourToThree = "4:3"

        mutating func toggle() {
            self = (self == .oneToOne) ? .fourToThree : .oneToOne
        }

        var preset: AVCaptureSession.Preset {
            switch self {
            case .oneToOne: .high
            case .fourToThree: .vga640x480
            }
        }
    }

    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    public var isRecordingPublisher: AnyPublisher<Bool, Never> {
        self.isRecordingSubject.eraseToAnyPublisher()
    }

    private let recordedURLSubject = PassthroughSubject<URL, Never>()
    public var recordedURLPublisher: AnyPublisher<URL, Never> {
        self.recordedURLSubject.eraseToAnyPublisher()
    }

    private let aspectRatioTextSubject = CurrentValueSubject<String, Never>("1:1")
    public var aspectRatioTextPublisher: AnyPublisher<String, Never> {
        self.aspectRatioTextSubject.eraseToAnyPublisher()
    }

    private let durationTextSubject = CurrentValueSubject<String, Never>("1초")
    public var durationTextPublisher: AnyPublisher<String, Never> {
        self.durationTextSubject.eraseToAnyPublisher()
    }

    private let authorizationSubject = PassthroughSubject<Bool, Never>()
    public var authorizationPublisher: AnyPublisher<Bool, Never> {
        self.authorizationSubject.eraseToAnyPublisher()
    }

    private let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let movieOutput = AVCaptureMovieFileOutput()

    public private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var previewContainer: UIView?

    private var isFrontCamera = false
    private var currentAspectRatio: AspectRatio = .oneToOne
    private var currentDurationIndex = 0
    private let durationOptions: [Int] = [1, 2, 3]

    private var recordingTimer: Timer?
    private var currentRecordingDuration: TimeInterval {
        Double(self.durationOptions[self.currentDurationIndex])
    }

    private var isUserCancelled: Bool = false

    override public init() {
        super.init()
    }

    deinit {
        recordingTimer?.invalidate()
    }

    public func requestAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.configureSession()
            self.authorizationSubject.send(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                self?.authorizationSubject.send(granted)
                if granted {
                    self?.configureSession()
                }
            }
        default:
            self.authorizationSubject.send(false)
        }
    }

    public func configureSession() {
        self.session.beginConfiguration()
        self.session.sessionPreset = self.currentAspectRatio.preset

        // Input
        if let currentInput = videoDeviceInput {
            self.session.removeInput(currentInput)
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            self.session.commitConfiguration()
            return
        }

        self.session.addInput(input)
        self.videoDeviceInput = input

        // Output
        if self.session.canAddOutput(self.movieOutput) {
            self.session.addOutput(self.movieOutput)
        }

        self.session.commitConfiguration()
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

    // MARK: - Preview

    public func configurePreview(in view: UIView, cornerRadius: CGFloat = 0) {
        self.previewContainer = view
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true

        DispatchQueue.main.async {
            view.layer.insertSublayer(layer, at: 0)
            self.previewLayer = layer
            self.updatePreviewLayout()
        }
    }

    public func updatePreviewLayout() {
        guard let container = previewContainer,
              let layer = previewLayer else { return }

        let width = container.bounds.width
        let height: CGFloat = (currentAspectRatio == .oneToOne)
            ? width
            : width * (4.0 / 3.0)

        DispatchQueue.main.async {
            layer.frame = CGRect(
                x: 0,
                y: (container.bounds.height - height) / 2,
                width: width,
                height: height
            )
        }
    }

    // MARK: - 버튼

    public func toggleRecording() {
        guard self.session.isRunning else { return }

        if self.movieOutput.isRecording {
            self.isUserCancelled = true
            self.movieOutput.stopRecording()
            self.isRecordingSubject.send(false)

            self.recordingTimer?.invalidate()
            self.recordingTimer = nil
        } else {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            self.isUserCancelled = false
            self.movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            self.isRecordingSubject.send(true)

            self.recordingTimer?.invalidate()
            self.recordingTimer = Timer.scheduledTimer(withTimeInterval: self.currentRecordingDuration, repeats: false) { [weak self] _ in
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

    public func changeAspectRatio() {
        self.currentAspectRatio.toggle()
        self.aspectRatioTextSubject.send(self.currentAspectRatio.rawValue)
        self.reconfigureSessionPreset()
        self.updatePreviewLayout()
    }

    public func changeDuration() {
        self.currentDurationIndex = (self.currentDurationIndex + 1) % self.durationOptions.count
        let value = self.durationOptions[self.currentDurationIndex]
        self.durationTextSubject.send("\(value)초")
    }

    private func reconfigureSessionPreset() {
        self.session.beginConfiguration()
        self.session.sessionPreset = self.currentAspectRatio.preset
        self.session.commitConfiguration()
    }

    public func duration(isRecording: Bool) -> Int {
        isRecording ? self.durationOptions[self.currentDurationIndex] : 0
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
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
