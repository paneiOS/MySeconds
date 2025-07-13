//
//  VideoClip.swift
//  SharedModels
//
//  Created by 이정환 on 6/12/25.
//

import UIKit

import UtilsKit

public protocol Clip: Codable, Hashable {
    var id: UUID { get }
    var duration: TimeInterval { get }
    var thumbnailData: Data? { get }
}

public struct VideoClip: Clip {
    public let id: UUID
    public let createdAt: Date
    public let fileName: String
    public let duration: TimeInterval

    public var thumbnailData: Data?

    public var thumbnail: UIImage? {
        self.thumbnailData.flatMap { UIImage(data: $0) }
    }

//    public var url: URL {
//        VideoClip.clipsFolder.appendingPathComponent(self.fileName + ".mp4")
//    }

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case fileName
        case duration
        case thumbnailData
    }

    public init(
        duration: TimeInterval,
        thumbnail: UIImage?
    ) {
        let uuid: UUID = .init()
        let date: Date = .init()
        self.id = uuid
        self.createdAt = date
        self.fileName = date.formattedString(format: "yyyyMMdd_HHmmssSSS") + "_" + self.id.uuidString
        self.duration = duration
        self.thumbnailData = thumbnail?.jpegData(compressionQuality: 0.8)
    }

//    private static let clipsFolder: URL = {
//        let fileManager = FileManager.default
//        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
//            // TODO: - Crashlytics 추가 예정
//            fatalError("⚠️ Application Support 디렉터리 접근 실패")
//        }
//
//        let folder = appSupport.appendingPathComponent("VideoClips", isDirectory: true)
//        do {
//            try fileManager.createDirectory(
//                at: folder,
//                withIntermediateDirectories: true
//            )
//        } catch {
//            // TODO: - Crashlytics 추가 예정
//            fatalError("⚠️ VideoClips 폴더 생성 실패: \(error)")
//        }
//        return folder
//    }()

    public func filePath(directoryURL: URL) -> URL {
        directoryURL.appendingPathComponent(self.fileName + ".mp4")
    }
}
