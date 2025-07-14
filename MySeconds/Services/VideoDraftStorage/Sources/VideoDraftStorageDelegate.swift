//
//  VideoDraftStorageDelegate.swift
//  VideoDraftStorage
//
//  Created by 이정환 on 6/5/25.
//

import Foundation

import SharedModels

public protocol VideoDraftStorageDelegate: AnyObject {
    var baseDirectoryURL: URL { get }
    func saveVideoClip(_ clip: VideoClip, at index: Int, into currentClips: [CompositionClip], sourceURL: URL) throws -> [CompositionClip]
    func saveVideoCoverMetadata(_ clip: VideoCoverClip, into currentClips: [CompositionClip]) throws -> [CompositionClip]
    func loadAll<T: Decodable>(type: T.Type) throws -> [T]
    func deleteVideo(fileName: String) throws
    func deleteAll() throws
    func updateClips(_ clips: [CompositionClip]) throws
}
