//
//  VideoDraftStorageTests.swift
//  VideoDraftStorageTests
//
//  Created by 이정환 on 6/6/25.
//

@testable import VideoDraftStorage
import XCTest

final class VideoDraftStorageTests: XCTestCase {

    private var storage: VideoDraftStoring?
    private let directoryName: String = "TestVideoDrafts"

    override func setUpWithError() throws {
        try self.deleteTestDirectory()
        self.storage = try VideoDraftStorage(directoryName: self.directoryName)
    }

    override func tearDownWithError() throws {
        try self.deleteTestDirectory()
        self.storage = nil
    }

    private func deleteTestDirectory() throws {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let dir = base.appendingPathComponent(self.directoryName, isDirectory: true)
        if FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.removeItem(at: dir)
        }
    }

    func test_임시영상_저장에_성공한다() throws {
        guard let storage else {
            XCTFail("저장소가 생성되지 않았습니다.")
            return
        }

        let draft = VideoDraft(
            id: UUID(),
            createdAt: Date(),
            duration: 3.0,
            thumbnailImageData: Data([0x01, 0x02]),
            videoData: Data([0x00, 0x11, 0x22])
        )

        XCTAssertNoThrow(try storage.save(draft))
    }

    func test_임시영상_불러오기에_성공한다() throws {
        guard let storage else {
            XCTFail("저장소가 생성되지 않았습니다.")
            return
        }

        let draft = VideoDraft(
            id: UUID(),
            createdAt: Date(),
            duration: 3.0,
            thumbnailImageData: Data([0x01, 0x02]),
            videoData: Data([0xAB, 0xCD])
        )

        try storage.save(draft)
        let loadedDraft = try storage.load(id: draft.id)

        XCTAssertEqual(loadedDraft.id, draft.id)
        XCTAssertEqual(loadedDraft.thumbnailImageData, draft.thumbnailImageData)
        XCTAssertEqual(loadedDraft.videoData, draft.videoData)
    }

    func test_임시영상_존재확인에_성공한다() throws {
        guard let storage else {
            XCTFail("저장소가 생성되지 않았습니다.")
            return
        }

        let draft = VideoDraft(
            id: UUID(),
            createdAt: Date(),
            duration: 3.0,
            thumbnailImageData: Data(),
            videoData: Data()
        )

        try storage.save(draft)
        XCTAssertTrue(storage.exists(id: draft.id))
    }
}
