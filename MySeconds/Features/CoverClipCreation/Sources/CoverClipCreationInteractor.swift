//
//  CoverClipCreationInteractor.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import Combine

import ModernRIBs

import BaseRIBsKit
import SharedModels

public protocol CoverClipCreationRouting: ViewableRouting {}

protocol CoverClipCreationPresentable: Presentable {
    var listener: CoverClipCreationPresentableListener? { get set }
}

public protocol CoverClipCreationListener: AnyObject {
    func applyVideoCoverClip(clip: VideoCoverClip)
    func closeCoverClipCreation()
}

final class CoverClipCreationInteractor: PresentableInteractor<CoverClipCreationPresentable>, CoverClipCreationInteractable {
    private let component: CoverClipCreationComponent

    private let coverTypeSubject = PassthroughSubject<VideoCoverClip.CoverType, Never>()
    public var coverTypePublisher: AnyPublisher<VideoCoverClip.CoverType, Never> {
        self.coverTypeSubject.eraseToAnyPublisher()
    }

    weak var router: CoverClipCreationRouting?
    weak var listener: CoverClipCreationListener?

    init(presenter: CoverClipCreationPresentable, component: CoverClipCreationComponent) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension CoverClipCreationInteractor: CoverClipCreationPresentableListener {
    func initCoverClipCreation() {
        self.coverTypeSubject.send(self.component.videoCoverClip.type)
    }

    func closeButtonTapped() {
        self.listener?.closeCoverClipCreation()
    }

    func addButtonTapped(clip: VideoCoverClip) {
        self.listener?.applyVideoCoverClip(clip: clip)
    }
}
