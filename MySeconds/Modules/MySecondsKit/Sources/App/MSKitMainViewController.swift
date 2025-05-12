//
//  MSKitMainViewController.swift
//  MySecondsKit
//
//  Created by Chung Wussup on 5/12/25.
//

import Combine
import UIKit

import ResourceKit

public final class MSKitMainViewController: UIViewController {
    let label = UILabel()

    private let navigationBar = MSNavigationBar()
    private let menuButtonTapped = PassthroughSubject<Void, Never>()
    private let imageButtonTapped = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()

    override public func viewDidLoad() {
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
        self.label.text = "Main View Controller"

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(self.navigationBar)

        self.navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        self.navigationBar.configure(
            showLogo: true,
            hasBackButton: false,
            rightButtons: [
                (
                    image: ResourceKitAsset.image.image,
                    tapPublisher: self.imageButtonTapped
                ),
                (
                    image: ResourceKitAsset.menu.image,
                    tapPublisher: self.menuButtonTapped
                )
            ]
        )
    }

    func bind() {
        self.menuButtonTapped
            .sink { [weak self] _ in
                guard let self else { return }
                print("Tap Menu Button")

                let thirdVC = MSKitSecondViewController()
                thirdVC.isPresent = false
                self.navigationController?.pushViewController(thirdVC, animated: true)
            }
            .store(in: &self.cancellables)

        self.imageButtonTapped
            .sink { [weak self] _ in
                guard let self else { return }
                let thirdVC = MSKitSecondViewController()
                thirdVC.isPresent = true
                let navigationController = UINavigationController(rootViewController: thirdVC)
                self.present(navigationController, animated: true)
            }
            .store(in: &self.cancellables)
    }
}
