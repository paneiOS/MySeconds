//
//  VideoDraftStorage.swift
//  MySeconds
//
//  Created by pane on 06/05/2025.
//

import Foundation

import SharedModels

public final class VideoDraftStorage: VideoDraftStorageDelegate {
    public enum Error: Swift.Error {
        case directoryNotFound
        case fileNotFound
        case corruptedData
    }

    private var fileManager: FileManager = .default
    private let videoDraftsFileURL: URL
    public let baseDirectoryURL: URL

    public init(directoryName: String = "VideoClips") throws {
        guard let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw Error.directoryNotFound
        }
        self.baseDirectoryURL = base.appendingPathComponent(directoryName, isDirectory: true)
        self.videoDraftsFileURL = self.baseDirectoryURL.appendingPathComponent("\(directoryName)Drafts.json")
        try self.fileManager.createDirectory(at: self.baseDirectoryURL, withIntermediateDirectories: true)
    }

    // MARK: - Public

    public func saveVideoClip(_ clip: VideoClip, at index: Int, into currentClips: [CompositionClip], sourceURL: URL) throws -> [CompositionClip] {
        try self.saveVideoDraft(sourceURL: sourceURL, fileName: clip.fileName)
        let updatedClips = self.insertClip(.video(clip), at: index, into: currentClips)
        try self.updateClips(updatedClips)
        return updatedClips
    }

    public func saveVideoCoverMetadata(_ clip: VideoCoverClip, into currentClips: [CompositionClip]) throws -> [CompositionClip] {
        var updatedClips = currentClips
        let coverClip = CompositionClip.cover(clip)
        if clip.type == .intro {
            updatedClips[0] = coverClip
        } else {
            updatedClips[currentClips.count - 1] = coverClip
        }
        return updatedClips
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

    public func updateClips(_ clips: [CompositionClip]) throws {
        let corrected = self.reorderIfNeeded(clips: clips)
        let data = try JSONEncoder().encode(corrected)
        try data.write(to: self.videoDraftsFileURL, options: .atomic)
    }

    // MARK: - Private

    private func videoFileURLPath(fileName: String) -> URL {
        self.baseDirectoryURL.appendingPathComponent(fileName + ".mp4")
    }

    private func reorderIfNeeded(clips: [CompositionClip]) -> [CompositionClip] {
        let intro = clips.first(where: CompositionClip.isIntro) ?? .cover(.init(title: nil, description: nil, type: .intro))
        let outro = clips.reversed().first(where: CompositionClip.isOutro) ?? .cover(.init(title: nil, description: nil, type: .outro))
        let body = clips.filter { !CompositionClip.isIntro($0) && !CompositionClip.isOutro($0) }
        return [intro] + body + [outro]
    }

    private func saveVideoDraft(sourceURL: URL, fileName: String) throws {
        guard self.fileManager.fileExists(atPath: sourceURL.path) else {
            throw Error.fileNotFound
        }
        let filePath = self.videoFileURLPath(fileName: fileName)
        try self.fileManager.copyItem(at: sourceURL, to: filePath)
        try? self.fileManager.removeItem(at: sourceURL)
    }

    private func insertClip(_ clip: CompositionClip, at index: Int, into clips: [CompositionClip]) -> [CompositionClip] {
        var newClips = clips
        let safeIndex = max(0, min(index, newClips.count))
        newClips.insert(clip, at: safeIndex)
        return newClips
    }
}
