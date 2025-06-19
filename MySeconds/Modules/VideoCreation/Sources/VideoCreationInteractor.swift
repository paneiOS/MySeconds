//
//  VideoCreationInteractor.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import Combine

import ModernRIBs

import BaseRIBsKit
import BGMSelect
import SharedModels

public protocol VideoCreationRouting: ViewableRouting {
    func apply(bgm: BGM)
}

protocol VideoCreationPresentable: Presentable {
    var listener: VideoCreationPresentableListener? { get set }
}

public protocol VideoCreationListener: AnyObject {
    func didSelectCoverClip(clip: VideoCoverClip)
    func bgmSelectButtonTapped()
}

final class VideoCreationInteractor: PresentableInteractor<VideoCreationPresentable>, VideoCreationInteractable {
    private let component: VideoCreationComponent

    private let clipsSubject = CurrentValueSubject<[CompositionClip], Never>([])
    public var clipsPublisher: AnyPublisher<[CompositionClip], Never> {
        self.clipsSubject.eraseToAnyPublisher()
    }

    private let selectedBGMSubject = CurrentValueSubject<BGM?, Never>(nil)
    public var selectedBGMPublisher: AnyPublisher<BGM?, Never> {
        self.selectedBGMSubject.eraseToAnyPublisher()
    }

    weak var router: VideoCreationRouting?
    weak var listener: VideoCreationListener?

    init(presenter: VideoCreationPresentable, component: VideoCreationComponent) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension VideoCreationInteractor: VideoCreationPresentableListener {
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

    func bgmSelectButtonTapped() {
        self.listener?.bgmSelectButtonTapped()
    }

    func apply(bgm: BGM) {
        self.selectedBGMSubject.send(bgm)
    }
}
