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
    case sessionConfigurationFailed
}

// MARK: - Delegate

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didStartRecording url: URL)
    func cameraManager(_ manager: CameraManager, didFinishRecording url: URL, error: Error?)
    func cameraManagerDidFailAuthorization(_ manager: CameraManager)
}

// MARK: - Protocol

protocol CameraManagerProtocol: AnyObject {
    var delegate: CameraManagerDelegate? { get set }
    var isAuthorized: Bool { get }
    var currentAspectRatioText: String { get }
    var recordingDurationText: String { get }
    var isRecording: Bool { get }

    func configurePreview(in view: UIView, cornerRadius: CGFloat)
    func requestAuthorizationAndStart()
    func toggleRecording()
    func toggleAspectRatio()
    func toggleDuration()
    func switchCamera()
    func updatePreviewLayout()
}

final class CameraManager: NSObject {
    enum AspectRatio: String, CaseIterable {
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

    weak var delegate: CameraManagerDelegate?
    private(set) var isAuthorized = false

    var currentAspectRatioText: String { self.aspectRatio.rawValue }
    var recordingDurationText: String { "\(Int(self.maxRecordingTime))초" }
    var isRecording: Bool { self.movieOutput.isRecording }

    // MARK: Private Properties

    private var aspectRatio: AspectRatio = .oneToOne
    private var maxRecordingTime: TimeInterval = 3
    private let durationOptions: [TimeInterval] = [3, 4, 5]

    private let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var previewContainer: UIView?
    private var recordingTask: Task<Void, Never>?

    override init() {
        super.init()
        self.session.beginConfiguration()
        self.session.sessionPreset = self.aspectRatio.preset

        guard self.session.canAddOutput(self.movieOutput) else {
            self.session.commitConfiguration()
            print("movie output add fail")
            return
        }

        self.session.addOutput(self.movieOutput)
        self.session.commitConfiguration()
    }
}

extension CameraManager: CameraManagerProtocol {
    func configurePreview(in view: UIView, cornerRadius: CGFloat) {
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

    func requestAuthorizationAndStart() {
        Task { @MainActor in
            do {
                try await requestPermission()
                self.isAuthorized = true
                try await configureCameraInput()

                DispatchQueue.global(qos: .background).async {
                    self.session.startRunning()
                }

            } catch {
                self.delegate?.cameraManagerDidFailAuthorization(self)
            }
        }
    }

    func toggleRecording() {
        guard self.isAuthorized else { return }
        if self.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func toggleAspectRatio() {
        guard self.isAuthorized else { return }
        self.aspectRatio.toggle()
        reconfigureSessionPreset()
        self.updatePreviewLayout()
    }

    func toggleDuration() {
        guard let idx = durationOptions.firstIndex(of: maxRecordingTime) else {
            self.maxRecordingTime = self.durationOptions.first ?? self.maxRecordingTime
            return
        }
        self.maxRecordingTime = self.durationOptions[(idx + 1) % self.durationOptions.count]
    }

    func switchCamera() {
        guard self.isAuthorized else { return }
        Task {
            await switchCameraInput()
        }
    }

    func updatePreviewLayout() {
        guard let container = previewContainer,
              let layer = previewLayer else { return }

        let width = container.bounds.width
        let height = width * (aspectRatio == .oneToOne ? 1 : 4 / 3)
        DispatchQueue.main.async {
            layer.frame = CGRect(
                x: 0,
                y: (container.bounds.height - height) / 2,
                width: width,
                height: height
            )
        }
    }
}

// MARK: - Recording

private extension CameraManager {
    func startRecording() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        self.movieOutput.startRecording(to: url, recordingDelegate: self)

        self.recordingTask?.cancel()
        self.recordingTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: UInt64(self.maxRecordingTime * 1_000_000_000))
                await MainActor.run { self.movieOutput.stopRecording() }
            } catch {}
        }
    }

    func stopRecording() {
        self.movieOutput.stopRecording()
        self.recordingTask?.cancel()
    }
}

// MARK: - Session Configuration

private extension CameraManager {
    func requestPermission() async throws {
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

    func configureCameraInput() async throws {
        try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.beginConfiguration()
                defer { self.session.commitConfiguration() }

                do {
                    guard let device = AVCaptureDevice.default(
                        .builtInWideAngleCamera, for: .video, position: .back
                    ) else { throw CameraError.noDevice }

                    let input = try AVCaptureDeviceInput(device: device)
                    guard self.session.canAddInput(input) else {
                        throw CameraError.unableToAddInput
                    }
                    self.session.addInput(input)
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    func reconfigureSessionPreset() {
        self.session.beginConfiguration()
        self.session.sessionPreset = self.aspectRatio.preset
        self.session.commitConfiguration()
    }

    func switchCameraInput() async {
        guard let current = session.inputs.first as? AVCaptureDeviceInput else { return }
        let newPos: AVCaptureDevice.Position = (current.device.position == .back) ? .front : .back

        do {
            guard let newDev = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: newPos
            ) else { throw CameraError.noDevice }

            let newInput = try AVCaptureDeviceInput(device: newDev)

            self.session.beginConfiguration()
            self.session.removeInput(current)
            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
            } else {
                self.session.addInput(current)
            }
            self.session.commitConfiguration()
        } catch {
            print("Camera switch error:", error)
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo url: URL,
        from connections: [AVCaptureConnection]
    ) {
        self.delegate?.cameraManager(self, didStartRecording: url)
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo url: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        Task {
            do {
                let cropped = try await VideoCropper.cropSquare(inputURL: url)
                self.delegate?.cameraManager(self, didFinishRecording: cropped, error: error)
            } catch {
                self.delegate?.cameraManager(self, didFinishRecording: url, error: error)
            }
        }
    }
}

// MARK: - VideoCropper

enum VideoCropper {
    static func cropSquare(inputURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: inputURL)
        let duration = try await asset.load(.duration)
        guard let track = try await asset.loadTracks(withMediaType: .video).first else {
            throw CameraError.noDevice
        }
        let transform = try await track.load(.preferredTransform)
        let size = try await track.load(.naturalSize).applying(transform).abs

        let square = min(size.width, size.height)
        let xOff = (size.width - square) / 2
        let yOff = (size.height - square) / 2

        let composition = AVMutableVideoComposition()
        composition.renderSize = CGSize(width: square, height: square)
        composition.frameDuration = CMTime(value: 1, timescale: 30)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = .init(start: .zero, duration: duration)

        let layerInst = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let move = CGAffineTransform(translationX: -xOff, y: -yOff)
        layerInst.setTransform(transform.concatenating(move), at: .zero)
        instruction.layerInstructions = [layerInst]
        composition.instructions = [instruction]

        guard let exporter = AVAssetExportSession(
            asset: asset, presetName: AVAssetExportPresetHighestQuality
        ) else { throw CameraError.sessionConfigurationFailed }

        let outURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        exporter.outputURL = outURL
        exporter.outputFileType = .mov
        exporter.videoComposition = composition

        if #available(iOS 18, *) {
            try await exporter.export(to: outURL, as: .mov)
        } else {
            await exporter.export()
        }
        return outURL
    }
}

private extension CGSize {
    var abs: CGSize { .init(width: Swift.abs(width), height: Swift.abs(height)) }
}
