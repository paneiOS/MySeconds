//
//  ViewControllable+Extension.swift
//  BaseRIBsKit
//
//  Created by 이정환 on 4/22/25.
//

import UIKit

import ModernRIBs

public extension ViewControllable {
    func present(viewController: ViewControllable, animated: Bool = true, completion: (() -> Void)? = nil) {
        uiviewController.present(viewController.uiviewController, animated: animated, completion: completion)
    }

    func dismiss(viewController _: ViewControllable, animated: Bool = true, completion: (() -> Void)? = nil) {
        uiviewController.dismiss(animated: animated, completion: completion)
    }
}
