//
//  VideoDraftStoring.swift
//  VideoDraftStorage
//
//  Created by 이정환 on 6/5/25.
//

import Foundation

public protocol VideoDraftStoring {
    func save(_ draft: VideoDraft) throws
    func load(id: UUID) throws -> VideoDraft
    func loadAll() throws -> [VideoDraft]
    func delete(id: UUID) throws
    func exists(id: UUID) -> Bool
}

enum VideoDraftStorageError: Error {
    case directoryNotFound
    case fileNotFound
}
