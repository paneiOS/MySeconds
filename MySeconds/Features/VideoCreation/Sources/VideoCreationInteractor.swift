//
//  VideoCreationInteractor.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import Combine
import Foundation

import ModernRIBs

import BaseRIBsKit
import BGMSelect
import SharedModels

public protocol VideoCreationRouting: ViewableRouting {
    func apply(bgm: BGM)
    func applyVideoCoverClip(clip: VideoCoverClip)
}

protocol VideoCreationPresentable: Presentable {
    var listener: VideoCreationPresentableListener? { get set }
}

public protocol VideoCreationListener: AnyObject {
    func didSelectCoverClip(clip: VideoCoverClip)
    func bgmSelectButtonTapped()
    func popToVideoCreation()
}

final class VideoCreationInteractor: PresentableInteractor<VideoCreationPresentable>, VideoCreationInteractable, VideoCreationPresentableListener {
    private let component: VideoCreationComponent

    private let clipsSubject = CurrentValueSubject<[CompositionClip], Never>([])
    public var clipsPublisher: AnyPublisher<[CompositionClip], Never> {
        self.clipsSubject.eraseToAnyPublisher()
    }

    private let selectedBGMSubject = CurrentValueSubject<BGM?, Never>(nil)
    public var selectedBGMPublisher: AnyPublisher<BGM?, Never> {
        self.selectedBGMSubject.eraseToAnyPublisher()
    }

    let directoryURL: URL
    weak var router: VideoCreationRouting?
    weak var listener: VideoCreationListener?

    init(presenter: VideoCreationPresentable, component: VideoCreationComponent) {
        self.component = component
        self.directoryURL = component.videoDraftStorage.baseDirectoryURL
        super.init(presenter: presenter)
        presenter.listener = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}

extension VideoCreationInteractor {
    func initClips() {
        self.clipsSubject.send(self.component.clips)
    }

    func update(clips: [CompositionClip]) {
        self.clipsSubject.send(clips)
    }

    func delete(clip: CompositionClip) {
        var current = self.clipsSubject.value
        guard let removeIndex = current.firstIndex(of: clip) else { return }
        current.remove(at: removeIndex)
        self.clipsSubject.send(current)
    }

    func didSelectCoverClip(clip: VideoCoverClip) {
        self.listener?.didSelectCoverClip(clip: clip)
    }

    func applyVideoCoverClip(clip: VideoCoverClip) {
        do {
            var drafts = try self.component.videoDraftStorage.loadAll(type: CompositionClip.self)
            let index = clip.type == .intro ? 0 : drafts.count - 1
            drafts[index] = .cover(clip)
            try self.component.videoDraftStorage.updateBackup(drafts)
            self.clipsSubject.send(drafts)
        } catch {
            print("적용 실패")
        }
    }

    func bgmSelectButtonTapped() {
        self.listener?.bgmSelectButtonTapped()
    }

    func apply(bgm: BGM) {
        self.selectedBGMSubject.send(bgm)
    }

    func popToVideoCreation() {
        self.listener?.popToVideoCreation()
    }
}
