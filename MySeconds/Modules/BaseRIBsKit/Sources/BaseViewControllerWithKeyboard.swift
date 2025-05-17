//
//  BaseViewControllerWithKeyboard.swift
//  MySecondsKit
//
//  Created by 이정환 on 5/17/25.
//

import UIKit

import SnapKit

open class BaseViewControllerWithKeyboard: BaseViewController {
    private var snapKeyboardConstraint: Constraint?
    public var adjustableSnapConstraint: Constraint?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.snapKeyboardConstraint == nil, let constraint = adjustableSnapConstraint {
            self.snapKeyboardConstraint = constraint
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let dration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: dration) {
            if let nsConstraint = self.snapKeyboardConstraint?.layoutConstraints.first {
                nsConstraint.constant = -frame.height
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let dration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: dration) {
            if let nsConstraint = self.snapKeyboardConstraint?.layoutConstraints.first {
                nsConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
}
