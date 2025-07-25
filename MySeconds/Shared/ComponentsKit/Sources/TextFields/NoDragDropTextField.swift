//
//  NoDragDropTextField.swift
//  ComponentsKit
//
//  Created by 이정환 on 5/12/25.
//

import UIKit

public final class NoDragDropTextField: UITextField {

    override public func didMoveToWindow() {
        super.didMoveToWindow()

        interactions
            .filter { $0 is UIDragInteraction || $0 is UIDropInteraction }
            .forEach(removeInteraction)
    }
}
