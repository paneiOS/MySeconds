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

public protocol VideoCreationRouting: ViewableRouting {
    func routeToCoverclipCreation(with clip: VideoCoverClip)
    func closeCoverClipCreation()
}

protocol VideoCreationPresentable: Presentable {
    var listener: VideoCreationPresentableListener? { get set }
}

public protocol VideoCreationListener: AnyObject {}

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

    func closeCoverClipCreation() {
        self.router?.closeCoverClipCreation()
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
        self.router?.routeToCoverclipCreation(with: clip)
    }
}
