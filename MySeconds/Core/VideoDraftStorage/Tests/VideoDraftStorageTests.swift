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

    func test_영상초안_저장하면_복사되어_URL이_반환된다() throws {
        guard let storage else {
            XCTFail("저장소가 생성되지 않았습니다.")
            return
        }

        let videoData = Data([0x00, 0x11, 0x22])
        let tempURL = try createTempVideoFile(with: videoData)
        let fileName = "testVideo"

        let savedURL = try storage.saveVideoDraft(sourceURL: tempURL, fileName: fileName)
        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))
    }

    func test_파일명으로_영상로드하면_정상적인_URL이_반환된다() throws {
        guard let storage else {
            XCTFail("저장소가 생성되지 않았습니다.")
            return
        }

        let videoData = Data([0x01, 0x02, 0x03])
        let tempURL = try createTempVideoFile(with: videoData)
        let fileName = "testLoad"

        _ = try storage.saveVideoDraft(sourceURL: tempURL, fileName: fileName)
        let loadedURL = try storage.loadVideo(fileName: fileName)
        XCTAssertTrue(FileManager.default.fileExists(atPath: loadedURL.path))
    }

    func test_파일명으로_영상삭제하면_파일이_제거된다() throws {
        guard let storage else {
            XCTFail("저장소가 생성되지 않았습니다.")
            return
        }

        let videoData = Data([0xAA, 0xBB])
        let tempURL = try createTempVideoFile(with: videoData)
        let fileName = "testDelete"

        _ = try storage.saveVideoDraft(sourceURL: tempURL, fileName: fileName)
        try storage.deleteVideo(fileName: fileName)

        XCTAssertThrowsError(try storage.loadVideo(fileName: fileName)) { error in
            guard case VideoDraftStorage.Error.fileNotFound = error else {
                XCTFail("예상된 에러가 아닙니다. error: \(error)")
                return
            }
        }
    }

    func test_전체삭제하면_디렉토리의_모든파일이_삭제된다() throws {
        guard let storage else {
            XCTFail("저장소가 생성되지 않았습니다.")
            return
        }

        let data1 = try createTempVideoFile(with: Data([0x11]))
        let data2 = try createTempVideoFile(with: Data([0x22]))
        _ = try storage.saveVideoDraft(sourceURL: data1, fileName: "one")
        _ = try storage.saveVideoDraft(sourceURL: data2, fileName: "two")

        try storage.deleteAll()

        let allFiles = try FileManager.default.contentsOfDirectory(atPath: storage.baseDirectoryURL.path)
        XCTAssertTrue(allFiles.isEmpty)
    }
}

extension VideoDraftStorageTests {
    private func deleteTestDirectory() throws {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let dir = base.appendingPathComponent(self.directoryName, isDirectory: true)
        if FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.removeItem(at: dir)
        }
    }

    private func createTempVideoFile(with data: Data) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
}
