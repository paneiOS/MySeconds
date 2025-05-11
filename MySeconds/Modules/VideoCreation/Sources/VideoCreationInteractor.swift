//
//  VideoCreationInteractor.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import Combine

import ModernRIBs

import BaseRIBsKit

public protocol VideoCreationRouting: ViewableRouting {}

protocol VideoCreationPresentable: Presentable {
    var listener: VideoCreationPresentableListener? { get set }
}

public protocol VideoCreationListener: AnyObject {}

final class VideoCreationInteractor: PresentableInteractor<VideoCreationPresentable>, VideoCreationInteractable, VideoCreationPresentableListener {
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

extension VideoCreationInteractor {
    func initClips() {
        self.clipsSubject.send(self.component.clips)
    }

    func move(clip: CompositionClip, to index: Int) {
        var current = self.clipsSubject.value
        guard let removeIndex = current.firstIndex(of: clip) else { return }
        let clip = current.remove(at: removeIndex)
        current.insert(clip, at: index)
        self.clipsSubject.send(current)
    }

    func delete(clip: CompositionClip) {
        var current = self.clipsSubject.value
        guard let removeIndex = current.firstIndex(of: clip) else { return }
        current.remove(at: removeIndex)
        self.clipsSubject.send(current)
    }
}
