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

    let timerButtonTextPublisher = PassthroughSubject<String, Never>()
    let ratioButtonTextPublisher = PassthroughSubject<String, Never>()
    let isRecordingPublisher = PassthroughSubject<Bool, Never>()
    let recordDurationPublisher = PassthroughSubject<TimeInterval, Never>()
    let albumPublisher = PassthroughSubject<(UIImage?, Int), Never>()

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
        self.viewDidLoadPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.initAlbum()
            })
            .store(in: &cancellables)

        self.recordControlView.recordTapPublisher
            .sink(receiveValue: { [weak self] in
                guard let self else { return }
                self.listener?.didTapRecord()
            })
            .store(in: &cancellables)

        self.recordControlView.flipTapPublisher
            .sink(receiveValue: { [weak self] in
                guard let self else { return }
                self.listener?.didTapFlip()
            })
            .store(in: &cancellables)

        self.recordControlView.ratioTapPublisher
            .sink(receiveValue: { [weak self] in
                guard let self else { return }
                self.listener?.didTapRatio()
            })
            .store(in: &cancellables)

        self.recordControlView.timerTapPublisher
            .sink(receiveValue: { [weak self] in
                guard let self else { return }
                self.listener?.didTapTimer()
            })
            .store(in: &cancellables)

        self.recordControlView.albumTapPublisher
            .sink(receiveValue: { [weak self] in
                guard let self else { return }
                self.listener?.didTapAlbum()
            })
            .store(in: &cancellables)

        self.timerButtonTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.recordControlView.setTimerButtonText(seconds: text)
            })
            .store(in: &cancellables)

        self.ratioButtonTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let self else { return }
                self.recordControlView.setRatioButtonText(text: text)
            })
            .store(in: &cancellables)

        self.isRecordingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isRecording in
                guard let self else { return }
                self.recordControlView.setRecordingState(isRecording)
            })
            .store(in: &cancellables)

        self.recordDurationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] duration in
                guard let self else { return }
                self.recordControlView.recordDuration = duration
            })
            .store(in: &cancellables)

        self.albumPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] thumb, count in
                guard let self else { return }
                self.recordControlView.updateAlbum(thumbnail: thumb, count: count)
            })
            .store(in: &cancellables)
    }

    func handleFlip() {
        print("카메라 플립 탭")
    }

    func handleAlbumTap() {
        print("앨범 버튼 탭")
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
