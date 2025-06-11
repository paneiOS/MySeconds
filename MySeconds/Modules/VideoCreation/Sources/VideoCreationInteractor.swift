//
//  VideoCreationInteractor.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import Combine

import ModernRIBs

import BaseRIBsKit
import SharedModels

public protocol VideoCreationRouting: ViewableRouting {}

protocol VideoCreationPresentable: Presentable {
    var listener: VideoCreationPresentableListener? { get set }
}

public protocol VideoCreationListener: AnyObject {
    func videoCreationDidSelectCoverClip(_ clip: VideoCoverClip)
}

final class VideoCreationInteractor: PresentableInteractor<VideoCreationPresentable>, VideoCreationInteractable {
    private let component: VideoCreationComponent

    private let clipsSubject = CurrentValueSubject<[CompositionClip], Never>([])
    public var clipsPublisher: AnyPublisher<[CompositionClip], Never> {
        self.clipsSubject.eraseToAnyPublisher()
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
        self.listener?.videoCreationDidSelectCoverClip(clip)
    }
}
