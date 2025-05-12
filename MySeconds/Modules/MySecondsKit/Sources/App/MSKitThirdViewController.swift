//
//  MSKitThirdViewController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import ResourceKit

class MSKitThirdViewController: UIViewController {
    let label = UILabel()

    var isPresent = false

    private let navigationBar = MSNavigationBar()
    private let closeButtonTapped = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupUI()
        self.bind()
    }

    func setupUI() {
        self.view.addSubviews(self.label)
        self.label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.label.text = self.isPresent ? "Present View Controller" : "Push View Controller"

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(self.navigationBar)

        self.navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        self.navigationBar.configure(
            showLogo: false,
            title: "Third View",
            hasBackButton: self.isPresent ? false : true,
            rightButtons: self.isPresent ? [
                (
                    image: ResourceKitAsset.close.image,
                    tapPublisher: self.closeButtonTapped
                )
            ] : []
        )
    }

    func bind() {
        self.closeButtonTapped
            .sink { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
    }
}
