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
import ResourceKit
import SharedModels
import VideoDraftStorage

public protocol VideoCreationRouting: ViewableRouting {
    func apply(bgm: BGM)
    func applyVideoCoverClip(clip: VideoCoverClip)
    func routeToBGMSelect(bgmDirectoryURL: URL)
    func closeBGMSelect()
}

protocol VideoCreationPresentable: Presentable {
    var listener: VideoCreationPresentableListener? { get set }
}

public protocol VideoCreationListener: AnyObject {
    func didSelectCoverClip(clip: VideoCoverClip)
    func popToVideoCreation()
    func didUpdateClips(_ clips: [CompositionClip])
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

    private var bgmDirectoryURL: URL? {
        ResourceKitResources.bundle.url(forResource: "BGMs", withExtension: nil)
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

    func updateClips(_ clips: [CompositionClip]) {
        guard clips != self.clipsSubject.value else { return }
        do {
            try self.component.videoDraftStorage.updateClips(clips)
            self.clipsSubject.send(clips)
            self.listener?.didUpdateClips(clips)
        } catch {
            // TODO: - 에러처리 필요
        }
    }

    func deleteClip(_ clip: CompositionClip) {
        var currentClips = self.clipsSubject.value
        guard let removeIndex = currentClips.firstIndex(of: clip) else { return }
        currentClips.remove(at: removeIndex)
        self.updateClips(currentClips)
    }

    func didSelectCoverClip(clip: VideoCoverClip) {
        self.listener?.didSelectCoverClip(clip: clip)
    }

    func applyVideoCoverClip(clip: VideoCoverClip) {
        do {
            let clips = try self.component.videoDraftStorage.saveVideoCoverMetadata(clip, into: self.clipsSubject.value)
            self.clipsSubject.send(clips)
        } catch {
            // TODO: - 에러처리 필요
        }
    }

    func bgmSelectButtonTapped() {
        guard let bgmDirectoryURL else { return }
        self.router?.routeToBGMSelect(bgmDirectoryURL: bgmDirectoryURL)
    }

    func apply(bgm: BGM) {
        self.selectedBGMSubject.send(bgm)
    }

    func popToVideoCreation() {
        self.listener?.popToVideoCreation()
    }

    func closeBGMSelect() {
        self.router?.closeBGMSelect()
    }
}
