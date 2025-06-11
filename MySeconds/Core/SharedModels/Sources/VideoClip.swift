//
//  VideoClip.swift
//  SharedModels
//
//  Created by 이정환 on 6/12/25.
//

import UIKit

import UtilsKit

public protocol Clip: Hashable {
    var id: UUID { get }
    var duration: TimeInterval { get }
    var thumbnail: UIImage? { get }
}

public struct VideoClip: Clip {
    public let id: UUID
    public let fileName: String
    public let createdAt: Date
    public var thumbnail: UIImage?
    public let duration: TimeInterval

    public var url: URL {
        VideoClip.clipsFolder.appendingPathComponent(self.fileName)
    }

    public init(
        id: UUID = .init(),
        fileName: String,
        createdAt: Date = .init(),
        duration: TimeInterval,
        thumbnail: UIImage? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.createdAt = createdAt
        self.duration = duration
        self.thumbnail = thumbnail
    }

    private static let clipsFolder: URL = {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
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

    public var fileBaseName: String {
        self.createdAt.formattedString(format: "yyyyMMdd_HHmmssSSS") + "_" + self.id.uuidString
    }
}
