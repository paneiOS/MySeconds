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

final class CoverClipCreationInteractor: PresentableInteractor<CoverClipCreationPresentable>, CoverClipCreationInteractable {

    weak var router: CoverClipCreationRouting?
    weak var listener: CoverClipCreationListener?

    init(presenter: CoverClipCreationPresentable, component: CoverClipCreationComponent) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension CoverClipCreationInteractor: CoverClipCreationPresentableListener {
    func closeButtonTapped() {
        // MARK: - 닫기 구현

        print("닫기 버튼 탭")
    }

    func addButtonTapped(with coverClip: CoverClip) {
        // MARK: - 추가 버튼 구현

        print("추가 버튼 탭", coverClip)
    }
}
