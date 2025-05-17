//
//  CoverClipCreationInteractor.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import ModernRIBs

import BaseRIBsKit

public protocol CoverClipCreationRouting: ViewableRouting {}

protocol CoverClipCreationPresentable: Presentable {
    var listener: CoverClipCreationPresentableListener? { get set }
}

public protocol CoverClipCreationListener: AnyObject {}

final class CoverClipCreationInteractor: PresentableInteractor<CoverClipCreationPresentable>, CoverClipCreationInteractable, CoverClipCreationPresentableListener {

    weak var router: CoverClipCreationRouting?
    weak var listener: CoverClipCreationListener?

    init(presenter: CoverClipCreationPresentable, component: CoverClipCreationComponent) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
