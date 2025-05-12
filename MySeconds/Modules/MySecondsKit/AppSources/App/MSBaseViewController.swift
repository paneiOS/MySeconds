//
//  MSBaseViewController.swift
//  MySecondsKitMoudleApp
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

class MSBaseViewController: UIViewController {

    public var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupUI()
        self.bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    open func setupUI() {}

    open func bind() {}
}

extension MSBaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        self.navigationController?.viewControllers.count ?? 0 > 1
    }
}
