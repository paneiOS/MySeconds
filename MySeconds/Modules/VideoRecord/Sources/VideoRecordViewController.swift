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
    var timerButtonTextPublisher: AnyPublisher<String, Never> { get }
    var ratioButtonTextPublisher: AnyPublisher<String, Never> { get }
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    var recordDurationPublisher: AnyPublisher<TimeInterval, Never> { get }

    var albumPublisher: AnyPublisher<(UIImage?, Int), Never> { get }

    func initAlbum()
    func didTapRecord()
    func didTapFlip()
    func didTapRatio()
    func didTapTimer()
    func didTapAlbum()

    // TODO: Sample App 테스트 위한 메서드
    func recordDidFinish()
}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, NavigationConfigurable {

    weak var listener: VideoRecordPresentableListener?

    private let recordControlView = RecordControlView(count: 15)

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
        self.bindViewEvents()
        self.bindStateBindings()
    }

    private func bindViewEvents() {
        let viewEvents: [(AnyPublisher<Void, Never>, () -> Void)] = [
            (viewDidLoadPublisher, { [weak self] in
                guard let self else { return }
                self.listener?.initAlbum()
            }),
            (self.recordControlView.recordTapPublisher, { [weak self] in
                guard let self else { return }
                self.listener?.didTapRecord()
            }),
            (self.recordControlView.flipTapPublisher, { [weak self] in
                guard let self else { return }
                self.listener?.didTapFlip()
            }),
            (self.recordControlView.ratioTapPublisher, { [weak self] in
                guard let self else { return }
                self.listener?.didTapRatio()
            }),
            (self.recordControlView.timerTapPublisher, { [weak self] in
                guard let self else { return }
                self.listener?.didTapTimer()
            }),
            (self.recordControlView.albumTapPublisher, { [weak self] in
                guard let self else { return }
                self.listener?.didTapAlbum()
            })
        ]

        for (publisher, action) in viewEvents {
            publisher
                .sink(receiveValue: { _ in
                    action()
                })
                .store(in: &cancellables)
        }
    }

    private func bindStateBindings() {
        self.listener?.timerButtonTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.recordControlView.setTimerButtonText(seconds: text)
            })
            .store(in: &cancellables)

        self.listener?.ratioButtonTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.recordControlView.setRatioButtonText(text: text)
            })
            .store(in: &cancellables)

        self.listener?.isRecordingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isRecording in
                guard let self else { return }
                self.recordControlView.setRecordingState(isRecording)
            })
            .store(in: &cancellables)

        self.listener?.recordDurationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] duration in
                guard let self else { return }
                self.recordControlView.recordDuration = duration
            })
            .store(in: &cancellables)

        self.listener?.albumPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] thumbnail, count in
                guard let self else { return }
                self.recordControlView.updateAlbum(thumbnail: thumbnail, count: count)
            })
            .store(in: &cancellables)
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
