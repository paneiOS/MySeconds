//
//  CameraPreviewView.swift
//  VideoRecord
//
//  Created by Chung Wussup on 7/1/25.
//

import AVFoundation
import UIKit

final class CameraPreviewView: UIView {
    private let previewView = PreviewLayerView()

    public var ratioType: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }

    var session: AVCaptureSession? {
        didSet {
            self.previewView.videoPreviewLayer?.session = self.session
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setupView() {
        self.addSubview(self.previewView)
        self.previewView.videoPreviewLayer?.videoGravity = .resizeAspectFill
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.width
        let height = width * self.ratioType
        let originY = max((bounds.height - height) / 2.0, 0)

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.previewView.frame = CGRect(x: 0, y: originY, width: width, height: height)
        }
    }

    func removeSession() {
        self.previewView.videoPreviewLayer?.session = nil
    }

    private final class PreviewLayerView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
            self.layer as? AVCaptureVideoPreviewLayer
        }
    }
}
