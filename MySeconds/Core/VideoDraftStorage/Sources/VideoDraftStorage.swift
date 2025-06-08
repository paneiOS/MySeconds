//
//  VideoDraftStorage.swift
//  MySeconds
//
//  Created by pane on 06/05/2025.
//

import Foundation

public final class VideoDraftStorage {
    private let baseDirectoryURL: URL

    public init(directoryName: String) throws {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw VideoDraftStorageError.directoryNotFound
        }
        self.baseDirectoryURL = base.appendingPathComponent(directoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: self.baseDirectoryURL, withIntermediateDirectories: true)
    }

    private func draftDirectory(for id: UUID) -> URL {
        self.baseDirectoryURL.appendingPathComponent(id.uuidString, isDirectory: true)
    }

    private func metadataURL(for id: UUID) -> URL {
        self.draftDirectory(for: id).appendingPathComponent("draft.json")
    }

    private func videoURL(for id: UUID) -> URL {
        self.draftDirectory(for: id).appendingPathComponent("video.mp4")
    }
}

extension VideoDraftStorage: VideoDraftStoring {
    public func save(_ draft: VideoDraft) throws {
        let folderURL = self.draftDirectory(for: draft.id)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let metadata = try JSONEncoder().encode(draft)
        try metadata.write(to: self.metadataURL(for: draft.id))
        try draft.videoData.write(to: self.videoURL(for: draft.id))
    }

    public func load(id: UUID) throws -> VideoDraft {
        let metadataURL = metadataURL(for: id)
        let videoURL = videoURL(for: id)
        guard FileManager.default.fileExists(atPath: metadataURL.path),
              FileManager.default.fileExists(atPath: videoURL.path) else {
            throw VideoDraftStorageError.fileNotFound
        }

        let metadata = try Data(contentsOf: metadataURL)
        let draft = try JSONDecoder().decode(VideoDraft.self, from: metadata)
        return try VideoDraft(
            id: draft.id,
            createdAt: draft.createdAt,
            duration: draft.duration,
            thumbnailImageData: draft.thumbnailImageData,
            videoData: Data(contentsOf: videoURL)
        )
    }

    public func exists(id: UUID) -> Bool {
        FileManager.default.fileExists(atPath: self.metadataURL(for: id).path) &&
            FileManager.default.fileExists(atPath: self.videoURL(for: id).path)
    }

    public func delete(id: UUID) throws {
        try FileManager.default.removeItem(at: self.draftDirectory(for: id))
    }

    public func loadAll() throws -> [VideoDraft] {
        let folderURLs = try FileManager.default.contentsOfDirectory(at: self.baseDirectoryURL, includingPropertiesForKeys: nil)
        return try folderURLs.compactMap { folderURL in
            let id = UUID(uuidString: folderURL.lastPathComponent)
            guard let id else { return nil }
            let metadataURL = metadataURL(for: id)
            let videoURL = videoURL(for: id)

            guard FileManager.default.fileExists(atPath: metadataURL.path),
                  FileManager.default.fileExists(atPath: videoURL.path) else {
                return nil
            }
            let metadata = try Data(contentsOf: metadataURL)
            let draft = try JSONDecoder().decode(VideoDraft.self, from: metadata)
            return try VideoDraft(
                id: draft.id,
                createdAt: draft.createdAt,
                duration: draft.duration,
                thumbnailImageData: draft.thumbnailImageData,
                videoData: Data(contentsOf: videoURL)
            )
        }
    }
}
