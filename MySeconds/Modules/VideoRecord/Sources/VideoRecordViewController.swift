//
//  VideoRecordViewController.swift
//  MySeconds
//
//  Created by chungwussup on 02/18/2025.
//

import SnapKit
import UIKit

import ModernRIBs

protocol VideoRecordPresentableListener: AnyObject {}

final class VideoRecordViewController: UIViewController, VideoRecordPresentable, VideoRecordViewControllable {

    // MARK: - UI Components

    private lazy var navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    weak var listener: VideoRecordPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeUI()
    }

    private func makeUI() {
        view.backgroundColor = .white
        view.addSubview(self.navigationBar)

        self.navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
    }
}
