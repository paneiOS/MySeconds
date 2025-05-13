//
//  VideoClip.swift
//  VideoCreation
//
//  Created by 이정환 on 4/29/25.
//

import UIKit

public struct VideoClip: Hashable {
    public let id: UUID
    public let fileName: String
    public var thumbnail: UIImage?

    public var url: URL {
        VideoClip.clipsFolder.appendingPathComponent(self.fileName)
    }

    public init(
        id: UUID = .init(),
        fileName: String,
        duration: TimeInterval,
        thumbnail: UIImage? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.thumbnail = thumbnail
    }

    private static let clipsFolder: URL = {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            // TODO: - Crashlytics 추가 예정
            fatalError("⚠️ Application Support 디렉터리 접근 실패")
        }

        let folder = appSupport.appendingPathComponent("VideoClips", isDirectory: true)
        do {
            try fileManager.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )
        } catch {
            // TODO: - Crashlytics 추가 예정
            fatalError("⚠️ VideoClips 폴더 생성 실패: \(error)")
        }
        return folder
    }()
}
