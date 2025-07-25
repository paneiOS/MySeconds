//
//  RootViewController.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/27/25.
//

import UIKit

import BaseRIBsKit
import ModernRIBs

protocol RootPresentableListener: AnyObject {}

final class RootViewController: BaseViewController, RootPresentable, RootViewControllable {

    weak var listener: RootPresentableListener?
}
