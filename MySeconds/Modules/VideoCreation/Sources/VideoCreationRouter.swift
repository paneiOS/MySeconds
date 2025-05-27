//
//  VideoCreationRouter.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ModernRIBs

import CoverClipCreation
import SharedModels

protocol VideoCreationInteractable: Interactable, CoverClipCreationListener {
    var router: VideoCreationRouting? { get set }
    var listener: VideoCreationListener? { get set }
}

protocol VideoCreationViewControllable: ViewControllable {}

final class VideoCreationRouter: ViewableRouter<VideoCreationInteractable, VideoCreationViewController>, VideoCreationRouting {
    private let component: VideoCreationComponent
    private var coverClipCreationRouter: CoverClipCreationRouting?

    init(
        interactor: VideoCreationInteractable,
        viewController: VideoCreationViewController,
        component: VideoCreationComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }

    func routeToCoverclipCreation(with videoCoverClip: VideoCoverClip) {
        guard self.coverClipCreationRouter == nil else { return }
        let router = self.component.coverClipCreationBuilder.build(withListener: self.interactor, videoCoverClip: videoCoverClip)
        self.coverClipCreationRouter = router
        self.viewControllable.present(child: router.viewControllable, animated: false)
        self.attachChild(router)
    }

    func closeCoverClipCreation() {
        guard let router = self.coverClipCreationRouter else { return }
        router.viewControllable.dismiss(animated: false)
        self.detachChild(router)
        self.coverClipCreationRouter = nil
    }
}
