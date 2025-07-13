//
//  KeyboardAdjustable.swift
//  ComponentsKit
//
//  Created by 이정환 on 5/21/25.
//

import Combine
import UIKit

public protocol KeyboardAdjustable: AnyObject {
    var adjustableConstraint: NSLayoutConstraint? { get }
    var cancellables: Set<AnyCancellable> { get set }
    func bindKeyboard()
}

public extension KeyboardAdjustable where Self: UIViewController {
    func bindKeyboard() {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
            .map(\.cgRectValue.height)
            .sink(receiveValue: { [weak self] height in
                guard let self,
                      let constraint = self.adjustableConstraint else {
                    return
                }
                UIView.animate(withDuration: 0.25) {
                    constraint.constant = -height
                    self.view.layoutIfNeeded()
                }
            })
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink(receiveValue: { [weak self] _ in
                guard let self,
                      let constraint = self.adjustableConstraint else {
                    return
                }
                UIView.animate(withDuration: 0.25) {
                    constraint.constant = 0
                    self.view.layoutIfNeeded()
                }
            })
            .store(in: &cancellables)
    }
}
