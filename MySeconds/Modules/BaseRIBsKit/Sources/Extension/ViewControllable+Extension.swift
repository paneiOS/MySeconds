//
//  ViewControllable+Extension.swift
//  BaseRIBsKit
//
//  Created by 이정환 on 4/22/25.
//

import UIKit

import ModernRIBs

public extension ViewControllable {
    func present(
        child viewController: ViewControllable,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.uiviewController.present(viewController.uiviewController, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.uiviewController.dismiss(animated: animated, completion: completion)
    }
}
