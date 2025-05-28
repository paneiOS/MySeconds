//
//  VideoRecordViewController.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import Combine
import UIKit

import BaseRIBsKit
import SnapKit

import MySecondsKit
import ResourceKit

protocol VideoRecordPresentableListener: AnyObject {
    var thumbnailPublisher: AnyPublisher<UIImage?, Never> { get }
    var albumCountPublisher: AnyPublisher<Int, Never> { get }

    func initAlbum()
}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, NavigationConfigurable {

    weak var listener: VideoRecordPresentableListener?

    private let recordControlView = RecordControlView()

    override func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubviews(self.recordControlView)

        self.recordControlView.snp.makeConstraints {
            $0.height.equalTo(136)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    override func bind() {
        self.viewDidLoadPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.initAlbum()
            })
            .store(in: &cancellables)

        self.recordControlView.recordTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                // TODO: 녹화 기능
                print("녹화")
                self.recordControlView.recordDuration = 3
            })
            .store(in: &cancellables)

        self.recordControlView.flipTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                // TODO: 카메라 플립 기능
                print("카메라 촬영 화면 변경")
            })
            .store(in: &cancellables)

        self.recordControlView.ratioTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                // TODO: 카메라 프리뷰화면 비율 변경 기능
                self.recordControlView.setRatioButtonText()
                print("카메라 비율 변경")
            })
            .store(in: &cancellables)

        self.recordControlView.timerTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                // TODO: 타이머 변경 기능
                self.recordControlView.setTimerButtonText(seconds: "4초")
                print("타이머 변경")
            })
            .store(in: &cancellables)

        self.recordControlView.albumTapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                print("Tap Album Button")
            })
            .store(in: &cancellables)

        if let listener {
            listener.thumbnailPublisher
                .combineLatest(listener.albumCountPublisher)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] thumbnail, count in
                    guard let self else { return }
                    self.recordControlView.updateAlbum(thumbnail: thumbnail, count: count)
                })
                .store(in: &cancellables)
        }
    }

    func navigationConfig() -> NavigationConfig {
        NavigationConfig(
            leftButtonType: .logo,
            rightButtonTypes: [
                .custom(
                    image: ResourceKitAsset.image.image,
                    tintColor: .neutral400,
                    action: .push(UIViewController())
                ),
                .custom(
                    image: ResourceKitAsset.menu.image,
                    tintColor: .neutral400,
                    action: .push(UIViewController())
                )
            ]
        )
    }
}

extension VideoRecordViewController {
    func setAlbum(thumbnail: UIImage?, count: Int) {
        self.recordControlView.updateAlbum(thumbnail: thumbnail, count: count)
    }
}
