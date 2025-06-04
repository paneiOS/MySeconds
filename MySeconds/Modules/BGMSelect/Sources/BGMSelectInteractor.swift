//
//  BGMSelectInteractor.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import AVFoundation
import Combine
import Foundation

import ModernRIBs

import BaseRIBsKit
import UtilsKit

public protocol BGMSelectRouting: ViewableRouting {}

protocol BGMSelectPresentable: Presentable {
    var listener: BGMSelectPresentableListener? { get set }
}

public protocol BGMSelectListener: AnyObject {}

final class BGMSelectInteractor: PresentableInteractor<BGMSelectPresentable>, BGMSelectInteractable {
    private let component: BGMSelectComponent
    private var audioPlayer: AVAudioPlayer?
    private let audioHandler = AudioPlayerHandler()

    private let bgmListSubject = PassthroughSubject<[BGM], Never>()
    public var bgmListPublisher: AnyPublisher<[BGM], Never> {
        self.bgmListSubject.eraseToAnyPublisher()
    }

    private let currentTimeSubject = CurrentValueSubject<TimeInterval, Never>(0)
    var currentTimePublisher: AnyPublisher<TimeInterval, Never> {
        self.currentTimeSubject.eraseToAnyPublisher()
    }

    weak var router: BGMSelectRouting?
    weak var listener: BGMSelectListener?
    private var timerCancellable: AnyCancellable?

    init(presenter: BGMSelectPresentable, component: BGMSelectComponent) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func initData() {
        Task {
            let bgmList = await self.loadBGMList()
            self.bgmListSubject.send(bgmList)
        }
    }

    func play(bgm: BGM) {
        let url = self.component.bgmDirectoryURL.appendingPathComponent(bgm.fileName + ".mp3")
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self.audioHandler
            self.audioHandler.didFinishPlaying = { [weak self] in
                guard let self else { return }
                self.stop()
            }
            self.audioPlayer = player
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()

            self.timerCancellable?.cancel()
            self.timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink(receiveValue: { [weak self] _ in
                    guard let self,
                          let player = self.audioPlayer,
                          player.isPlaying else {
                        return
                    }
                    self.currentTimeSubject.send(player.currentTime)
                })
        } catch {
            // TODO: - 에러처리
        }
    }

    func stop() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.currentTimeSubject.send(0)
        self.timerCancellable?.cancel()
    }

    private func loadBGMList() async -> [BGM] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: component.bgmDirectoryURL,
            includingPropertiesForKeys: nil
        ).filter({ $0.pathExtension == "mp3" }) else {
            return []
        }
        return await urls.map { url in
            Task {
                let asset = AVURLAsset(url: url)
                guard let duration = try? await asset.load(.duration).seconds,
                      let fileName = url.lastPathComponent.components(separatedBy: ".").first else {
                    return nil
                }
                return BGM(fileName: fileName, bpm: 90, duratuion: duration, category: "발랄함")
            }
        }
        .asyncCompactMap { await $0.value }
    }
}

extension BGMSelectInteractor: BGMSelectPresentableListener {
    func applyButtonTapped(bgm: BGM) {
        // TODO: - 적용 버튼 구현
    }

    func closeButtonTapped() {
        // TODO: - 닫기 버튼 구현
    }
}

private class AudioPlayerHandler: NSObject, AVAudioPlayerDelegate {
    var didFinishPlaying: (() -> Void)?

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.didFinishPlaying?()
    }
}
