//
//  VideoDraftStorage.swift
//  MySeconds
//
//  Created by pane on 06/05/2025.
//

import Foundation

public final class VideoDraftStorage: VideoDraftStoring {
    public enum Error: Swift.Error {
        case directoryNotFound
        case fileNotFound
        case corruptedData
    }

    private var fileManager: FileManager = .default
    private let videoDraftsFileURL: URL
    public let baseDirectoryURL: URL

    public init(directoryName: String = "VideoDrafts") throws {
        guard let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw Error.directoryNotFound
        }
        self.baseDirectoryURL = base.appendingPathComponent(directoryName, isDirectory: true)
        self.videoDraftsFileURL = self.baseDirectoryURL.appendingPathComponent("VideoDrafts.json")
        try self.fileManager.createDirectory(at: self.baseDirectoryURL, withIntermediateDirectories: true)
    }

    // MARK: - Public

    public func saveVideoDraft(sourceURL: URL, fileName: String) throws -> URL {
        guard self.fileManager.fileExists(atPath: sourceURL.path) else {
            throw Error.fileNotFound
        }
        let filePath = self.videoFileURLPath(fileName: fileName)
        try self.fileManager.copyItem(at: sourceURL, to: filePath)
        try? self.fileManager.removeItem(at: sourceURL)
        return filePath
    }

    public func loadVideo(fileName: String) throws -> URL {
        let videoURL = self.videoFileURLPath(fileName: fileName)
        guard self.fileManager.fileExists(atPath: videoURL.path) else {
            throw Error.fileNotFound
        }
        return videoURL
    }

    public func loadAll<T: Decodable>(type: T.Type) throws -> [T] {
        let videoDraftsFileURL = self.videoDraftsFileURL
        guard self.fileManager.fileExists(atPath: videoDraftsFileURL.path) else { return [] }
        let data = try Data(contentsOf: videoDraftsFileURL)
        return try JSONDecoder().decode([T].self, from: data)
    }

    public func deleteVideo(fileName: String) throws {
        let fileURL = self.videoFileURLPath(fileName: fileName)
        if self.fileManager.fileExists(atPath: fileURL.path) {
            try self.fileManager.removeItem(at: fileURL)
        }
    }

    public func deleteAll() throws {
        if self.fileManager.fileExists(atPath: self.baseDirectoryURL.path) {
            try self.fileManager.removeItem(at: self.baseDirectoryURL)
        }
        try self.fileManager.createDirectory(at: self.baseDirectoryURL, withIntermediateDirectories: true)
    }

    public func updateBackup(_ items: [some Encodable]) throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: self.videoDraftsFileURL, options: .atomic)
    }

    // MARK: - Private

    private func videoFileURLPath(fileName: String) -> URL {
        self.baseDirectoryURL.appendingPathComponent(fileName + ".mp4")
    }
}
