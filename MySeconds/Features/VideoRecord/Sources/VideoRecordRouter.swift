//
//  VideoRecordRouter.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import Combine
import UIKit

import ModernRIBs

import BaseRIBsKit
import ComponentsKit
import ExtensionKit
import ResourceKit
import SharedModels
import VideoCreation

protocol VideoRecordInteractable: Interactable, VideoCreationListener {
    var router: VideoRecordRouting? { get set }
    var listener: VideoRecordListener? { get set }
}

protocol VideoRecordViewControllable: ViewControllable {}

final class VideoRecordRouter: ViewableRouter<VideoRecordInteractor, VideoRecordViewController> {
    private let component: VideoRecordComponent
    private var videoCreationRouter: VideoCreationRouting?
    private var cancellables = Set<AnyCancellable>()

    init(
        interactor: VideoRecordInteractor,
        viewController: VideoRecordViewController,
        component: VideoRecordComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension VideoRecordRouter {
    func showAlbumRIB() {
        print("pane_앨범탭")
    }

    func showMenuRIB() {
        print("pane_메뉴탭")
    }
}

// MARK: - private

extension VideoRecordRouter {
    private func backButton() -> UIButton {
        let button: UIButton = .init()
        let backImage: UIImage = ResourceKitAsset.chevronLeft.image
            .withRenderingMode(.alwaysTemplate)
            .resized(to: .init(width: 24, height: 24))
            .withTintColor(.neutral800)
        button.setImage(backImage, for: .normal)
        return button
    }

    private func bindNavigationEvents() {
        guard let delegate = self.viewController.navigationController?.delegate as? NavigationDelegateProxy else { return }
        delegate.popedViewControllerPublisher
            .sink(receiveValue: { [weak self] poppedVC in
                guard let self,
                      let videoCreationRouter,
                      poppedVC === videoCreationRouter.uiviewController else {
                    return
                }
                self.popToVideoCreation()
            })
            .store(in: &self.cancellables)
    }
}

private extension UIViewController {
    func setAttributedTitle(_ attributedTitle: NSAttributedString) {
        let label = UILabel()
        label.attributedText = attributedTitle
        label.sizeToFit()
        self.navigationItem.titleView = label
    }
}

extension VideoRecordRouter: VideoRecordRouting {

    // MARK: - VideoCreation(영상제작)

    func routeToVideoCreation(clips: [CompositionClip]) {
        guard self.videoCreationRouter == nil else { return }
        let videoCreationRouter = self.component.videoCreationBuilder.build(withListener: self.interactor, clips: clips)
        videoCreationRouter.uiviewController.navigationOption = .showsNavigationBar
        self.videoCreationRouter = videoCreationRouter
        self.attachChild(videoCreationRouter)

        let backButton = self.backButton()
        backButton.addTarget(self, action: #selector(self.popToVideoCreation), for: .touchUpInside)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        videoCreationRouter.uiviewController.navigationItem.leftBarButtonItem = backBarButtonItem
        let title: NSAttributedString = .makeAttributedString(
            text: "영상 만들기",
            font: .systemFont(ofSize: 16, weight: .regular),
            textColor: .neutral800,
            alignment: .center
        )
        videoCreationRouter.uiviewController.setAttributedTitle(title)
        self.viewController.navigationController?.pushViewController(videoCreationRouter.uiviewController, animated: true)
        self.bindNavigationEvents()
    }

    @objc func popToVideoCreation() {
        guard let videoCreationRouter else { return }
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self else { return }
            self.detachChild(videoCreationRouter)
            self.videoCreationRouter = nil
            self.cancellables.removeAll()
        }
        self.viewController.navigationController?.popViewController(animated: true)
        CATransaction.commit()
    }
}
