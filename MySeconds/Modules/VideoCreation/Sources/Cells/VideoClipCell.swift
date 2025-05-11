//
//  VideoClipCell.swift
//  VideoCreation
//
//  Created by 이정환 on 5/5/25.
//

import AVFoundation
import UIKit

import ResourceKit
import UtilsKit

public protocol ThumbnailGenerating {
    func thumbnail(for url: URL, size: CGSize, at time: CMTime) async -> UIImage?
}

final class VideoClipCell: UICollectionViewCell {
    private let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .neutral100
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private var thumbnailTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.thumbnailTask?.cancel()
        self.thumbnailView.image = nil
    }

    private func setupUI() {
        contentView.addSubview(self.thumbnailView)

        self.thumbnailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func drawCell(data: VideoClip) {
        if let image = data.thumbnail {
            self.thumbnailView.image = image
            return
        }

        self.thumbnailTask = Task { [weak self] in
            guard let self else { return }

            let asset = AVURLAsset(url: data.url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            generator.maximumSize = VideoCreationViewController.Constants.thumbnailSize

            do {
                let cgImage = try await generator.image(at: .zero)
                let image = UIImage(cgImage: cgImage.image)
                await MainActor.run {
                    self.thumbnailView.image = image
                }
            } catch {
                // TODO: - Crashlytics 추가 예정
                print("썸네일 생성 실패:", error)
            }
        }
    }
}
