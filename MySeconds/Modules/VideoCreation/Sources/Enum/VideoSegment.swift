//
//  VideoSegment.swift
//  VideoCreation
//
//  Created by 이정환 on 4/29/25.
//

import Foundation

public struct VideoSegment {
    public let id: UUID
    public let url: URL
    public let duration: TimeInterval
    public enum Source {
        case temporaryFile
        case photoLibrary(localIdentifier: String)
        case bundleResource(name: String)
    }

    public let source: Source
}
