//
//  VideoRecordViewController.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import UIKit

import BaseRIBsKit

import MySecondsKit
import ResourceKit

protocol VideoRecordPresentableListener: AnyObject {}

final class VideoRecordViewController: BaseViewController, VideoRecordPresentable, VideoRecordViewControllable, NavigationConfigurable {

    weak var listener: VideoRecordPresentableListener?

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
