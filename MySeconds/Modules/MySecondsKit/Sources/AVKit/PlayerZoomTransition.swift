//
//  PlayerZoomTransition.swift
//  MySecondsKit
//
//  Created by 이정환 on 5/13/25.
//
//

import AVKit
import UIKit

public final class PlayerZoomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public var frame: CGRect
    public var player: AVPlayer
    private let duration: TimeInterval

    public init(frame: CGRect, player: AVPlayer, duration: TimeInterval) {
        self.frame = frame
        self.player = player
        self.duration = duration
    }

    public func transitionDuration(using: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.duration
    }

    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        let container = context.containerView
        Task {
            guard let toViewController = context.viewController(forKey: .to) as? AVPlayerViewController,
                  let aspect = try? await self.aspect(for: self.player, in: container) else {
                context.completeTransition(false)
                return
            }
            let finalFrame: CGRect = self.centeredFit(aspect: aspect, in: container.bounds)

            let blackView: UIView = .init()
            blackView.backgroundColor = .black
            blackView.frame = container.bounds
            blackView.alpha = 0
            container.addSubview(blackView)

            let tempView = UIView(frame: self.frame)
            container.addSubview(tempView)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.videoGravity = .resize
            playerLayer.frame = tempView.bounds
            tempView.layer.addSublayer(playerLayer)
            toViewController.view.frame = container.bounds
            toViewController.view.alpha = 0
            container.addSubview(toViewController.view)

            let originalFrame = tempView.frame
            let scaleX = finalFrame.width / originalFrame.width
            let scaleY = finalFrame.height / originalFrame.height
            let animator = UIViewPropertyAnimator(duration: self.duration, curve: .easeInOut)
            animator.addAnimations {
                tempView.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                tempView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                blackView.alpha = 1
            }
            animator.startAnimation()
            let position = await animator.addCompletion()
            if position == .end {
                toViewController.view.alpha = 1
                tempView.removeFromSuperview()
                blackView.removeFromSuperview()
                context.completeTransition(true)
                self.player.play()
            }
        }
    }

    private func aspect(for player: AVPlayer, in container: UIView) async throws -> CGSize {
        guard let avAsset = player.currentItem?.asset as? AVURLAsset,
              let track = try? await avAsset.loadTracks(withMediaType: .video).first,
              let naturalSize = try? await track.load(.naturalSize),
              let transform = try? await track.load(.preferredTransform) else {
            return container.bounds.size
        }
        let rawSize = naturalSize.applying(transform)
        return CGSize(width: abs(rawSize.width), height: abs(rawSize.height))
    }

    private func centeredFit(aspect: CGSize, in container: CGRect) -> CGRect {
        let fullWidth = container.width
        let scaledHeight = fullWidth * (aspect.height / aspect.width)
        let originY = (container.height - scaledHeight) / 2
        return CGRect(x: 0, y: originY, width: fullWidth, height: scaledHeight)
    }
}
