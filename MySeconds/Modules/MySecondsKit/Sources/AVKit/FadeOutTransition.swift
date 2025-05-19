//
//  FadeOutTransition.swift
//  MySecondsKit
//
//  Created by 이정환 on 5/14/25.
//

import AVKit
import UIKit

public final class FadeOutTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    public init(duration: TimeInterval) {
        self.duration = duration
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        let container = transitionContext.containerView
        container.addSubview(fromView)
        UIView.animate(withDuration: self.duration, animations: {
            fromView.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
