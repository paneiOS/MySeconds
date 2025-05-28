//
//  BGMSelectViewController.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import Combine
import UIKit

import BaseRIBsKit
import MySecondsKit

protocol BGMSelectPresentableListener: AnyObject {
}

final class BGMSelectViewController: BaseBottomSheetViewController, BGMSelectPresentable, BGMSelectViewControllable {

    weak var listener: BGMSelectPresentableListener?
}
