//
//  BaseBottomSheetViewController.swift
//  ComponentsKit
//
//  Created by 이정환 on 5/22/25.
//

import Combine
import UIKit

import SnapKit

import BaseRIBsKit
import ResourceKit
import UtilsKit

public protocol BaseBottomSheetPresentable: AnyObject {
    var closeTappedPublisher: AnyPublisher<Bool, Never> { get }
}

open class BaseBottomSheetViewController: BaseViewController {
    // MARK: - UI Components

    public let dimmedView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .clear.withAlphaComponent(0.5)
        return view
    }()

    public let contentsView: UIView = {
        let view: UIView = .init()
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = .white
        return view
    }()

    public let sheetContainerView = UIView()

    public let headerView: UIView = .init()

    public let headerLabel = UILabel()

    private let closeButton: UIControl = .init()

    public let closeButtonView: UIView = {
        let view: UIView = .init()
        let closeImage = ResourceKitAsset.close.image.resized(to: .init(width: 20, height: 20))
            .withRenderingMode(.alwaysTemplate)
        let imageView: UIImageView = .init(image: closeImage)
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .init(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 0.2)
        imageView.tintColor = .init(red: 61 / 255, green: 61 / 255, blue: 61 / 255, alpha: 0.5)

        view.addSubviews(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }
        return view
    }()

    public let contentContainer = UIView()

    // MARK: - Properties

    public var adjustableSnapConstraint: Constraint?

    private let closeTappedSubject = PassthroughSubject<Bool, Never>()

    private var baseCancellables = Set<AnyCancellable>()

    // MARK: – Override func

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.contentsView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.3, animations: {
            self.contentsView.transform = .identity
        })
    }

    override open func setupUI() {
        super.setupUI()

        self.view.backgroundColor = .clear
        self.view.addSubview(self.dimmedView)
        self.dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.dimmedView.addSubview(self.contentsView)
        self.contentsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            self.adjustableSnapConstraint = $0.bottom.equalToSuperview().constraint
        }

        self.contentsView.addSubviews(self.headerView, self.sheetContainerView)
        self.headerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(58)
        }
        self.headerView.addSubviews(self.headerLabel, self.closeButtonView)
        self.headerLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        self.closeButtonView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(2)
            $0.size.equalTo(58)
        }
        self.closeButtonView.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.sheetContainerView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(50)
        }
    }

    override open func bind() {
        super.bind()

        self.closeButton.publisher(for: .touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.dimmedView.backgroundColor = .clear
                UIView.animate(withDuration: 0.3, animations: {
                    self.contentsView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                }, completion: { _ in
                    self.dismiss(animated: false) {
                        self.closeTappedSubject.send(true)
                    }
                })
            })
            .store(in: &self.baseCancellables)
    }
}

extension BaseBottomSheetViewController: BaseBottomSheetPresentable {
    public var closeTappedPublisher: AnyPublisher<Bool, Never> {
        self.closeTappedSubject.eraseToAnyPublisher()
    }
}
