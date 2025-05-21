//
//  BaseBottomSheetViewController.swift
//  MySecondsKit
//
//  Created by 이정환 on 5/22/25.
//

import UIKit

import SnapKit

import BaseRIBsKit
import ResourceKit
import UtilsKit

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

    public let closeButton: UIButton = {
        let button: UIButton = .init()
        let image: UIImage = ResourceKitAsset.close.image.resized(to: .init(width: 20, height: 20))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.backgroundColor = .init(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 0.2)
        button.tintColor = .init(red: 61 / 255, green: 61 / 255, blue: 61 / 255, alpha: 0.5)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()

    public let contentContainer = UIView()

    // MARK: - Properties
    
    public var adjustableSnapConstraint: Constraint?

    // MARK: – Override func

    override open func setupUI() {
        super.setupUI()

        self.view.addSubview(self.dimmedView)
        self.dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.dimmedView.addSubview(self.contentsView)
        self.contentsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            self.adjustableSnapConstraint = $0.bottom.equalToSuperview().constraint
        }

        self.contentsView.addSubview(self.sheetContainerView)
        self.sheetContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(50)
        }

        self.sheetContainerView.addSubviews(self.headerLabel, self.closeButton)
        self.headerLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        self.closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(30)
        }
    }
}
