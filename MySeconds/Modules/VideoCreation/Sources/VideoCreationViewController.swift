//
//  VideoCreationViewController.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import UIKit

import BaseRIBsKit

protocol VideoCreationPresentableListener: AnyObject {}

final class VideoCreationViewController: UIViewController, VideoCreationPresentable, VideoCreationViewControllable {

    weak var listener: VideoCreationPresentableListener?
}
