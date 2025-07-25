//
//  VideoView.swift
//  ComponentsKit
//
//  Created by JeongHwan Lee on 1/27/25.
//

import AVFoundation
import UIKit

import UtilsKit

public final class VideoView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    public init(player: AVPlayer, isRepeat: Bool = true) {
        self.player = player
        self.playerLayer = AVPlayerLayer(player: player)
        super.init(frame: .zero)

        guard let playerLayer else { return }
        playerLayer.cornerRadius = 24
        playerLayer.masksToBounds = true
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        player.play()

        if isRepeat {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.replay),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        }

        self.applyShadow(
            color: .init(red: 0, green: 0, blue: 0, alpha: 0.15),
            x: 0,
            y: 0,
            blur: 32,
            spread: 0
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = bounds
    }

    @objc private func replay() {
        self.player?.seek(to: .zero)
        self.player?.play()
    }
}
