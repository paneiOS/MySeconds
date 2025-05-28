//
//  BGMSelectInteractor.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import Combine

import ModernRIBs

import BaseRIBsKit

public protocol BGMSelectRouting: ViewableRouting {}

protocol BGMSelectPresentable: Presentable {
    var listener: BGMSelectPresentableListener? { get set }
}

public protocol BGMSelectListener: AnyObject {}

final class BGMSelectInteractor: PresentableInteractor<BGMSelectPresentable>, BGMSelectInteractable, BGMSelectPresentableListener {
    private let component: BGMSelectComponent
    
    weak var router: BGMSelectRouting?
    weak var listener: BGMSelectListener?

    init(presenter: BGMSelectPresentable, component: BGMSelectComponent) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }
}
