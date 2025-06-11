//
//  VideoDraftStoring.swift
//  VideoDraftStorage
//
//  Created by 이정환 on 6/5/25.
//

import Foundation

public protocol VideoDraftStoring {
    var baseDirectoryURL: URL { get }
    func saveVideoDraft(sourceURL: URL, fileName: String) throws -> URL
    func loadVideo(fileName: String) throws -> URL
    func loadAll<T: Decodable>(type: T.Type) throws -> [T]
    func deleteVideo(fileName: String) throws
    func deleteAll() throws
    func updateBackup<T: Encodable>(_ items: [T]) throws
}
