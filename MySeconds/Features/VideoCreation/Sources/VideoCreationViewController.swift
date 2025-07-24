//
//  VideoCreationViewController.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import AVKit
import Combine
import UIKit

import SnapKit

import BaseRIBsKit
import BGMSelect
import ComponentsKit
import CoverClipCreation
import ResourceKit
import SharedModels
import UtilsKit

protocol VideoCreationPresentableListener: AnyObject {
    var clipsPublisher: AnyPublisher<[CompositionClip], Never> { get }
    var selectedBGMPublisher: AnyPublisher<BGM?, Never> { get }
    var directoryURL: URL { get }
    func initClips()
    func update(clips: [CompositionClip])
    func delete(clip: CompositionClip)
    func didSelectCoverClip(clip: VideoCoverClip)
    func bgmSelectButtonTapped()
    func popToVideoCreation()
}

final class VideoCreationViewController: BaseViewController, VideoCreationPresentable, VideoCreationViewControllable {
    enum Constants {
        private static let maximumColumn: Int = 4
        private static let collectionViewInsets: CGFloat = 24.0
        static let makeButtonDuration: CGFloat = 1
        static let cellSpacing: CGFloat = 4
        static let cellSize: CGSize = {
            let totalSpacing = collectionViewInsets * 2
                + CGFloat(maximumColumn - 1) * cellSpacing
            let screenWidth = UIScreen.main.bounds.width
            let cellWidth = (screenWidth - totalSpacing) / CGFloat(maximumColumn)
            return .init(width: cellWidth, height: cellWidth)
        }()

        static let thumbnailSize: CGSize = .init(width: cellSize.width * 2, height: cellSize.height * 2)
        static let contentViewSpacing: CGFloat = 32
        static let initialSelectedSegmentIndex: Int = 2
        static let bgmIndex: Int = 1
    }

    enum Section {
        case main
    }

    // MARK: - UI Components

    private let totalView: UIView = .init()

    private let contentsSubview: UIView = .init()

    private let makeButton: UIButton = {
        let button: UIButton = .init()
        var configuration: UIButton.Configuration = .plain()
        configuration.image = ResourceKitAsset.wand.image
        configuration.attributedTitle = .init(.makeAttributedString(
            text: "길게 눌러 만들기",
            font: .systemFont(ofSize: 18, weight: .medium),
            textColor: .white
        ))
        configuration.imagePadding = 8
        configuration.imageColorTransformer = UIConfigurationColorTransformer { _ in .white }
        button.configuration = configuration
        button.backgroundColor = .neutral400
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let titleView: UIView = .init()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "제목",
            font: .systemFont(ofSize: 14, weight: .medium),
            textColor: .neutral600,
            alignment: .center
        )
        return label
    }()

    private lazy var titleTextField: NoDragDropTextField = {
        let textField: NoDragDropTextField = .init()
        textField.borderStyle = .none
        textField.attributedPlaceholder = .makeAttributedString(
            text: Date().dateToString,
            font: .systemFont(ofSize: 32, weight: .bold),
            textColor: .neutral400,
            alignment: .center
        )
        textField.textColor = .neutral600
        textField.font = .systemFont(ofSize: 32, weight: .bold)
        textField.textAlignment = .center
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    lazy var dataSource = UICollectionViewDiffableDataSource<Section, CompositionClip>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
        guard let self else { fatalError("❌ VC가 메모리에서 해제되기 전에 호출될 일은 없습니다.") }
        switch item {
        case let .cover(coverData):
            let cell = collectionView.dequeueReusableCell(CoverClipCell.self, for: indexPath)
            cell.drawCell(data: coverData)
            return cell

        case let .video(videoData):
            guard let listener else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(VideoClipCell.self, for: indexPath)
            cell.drawCell(data: videoData, directoryURL: listener.directoryURL)
            return cell
        }
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = Constants.cellSize
        layout.minimumInteritemSpacing = Constants.cellSpacing
        layout.minimumLineSpacing = Constants.cellSpacing
        let collectionView = IntrinsicCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dragInteractionEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(CoverClipCell.self, forCellWithReuseIdentifier: CoverClipCell.reuseIdentifier)
        collectionView.register(VideoClipCell.self, forCellWithReuseIdentifier: VideoClipCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        return collectionView
    }()

    private let segmentedControl: ImageTitleSegmentedControl = {
        let control: ImageTitleSegmentedControl = .init()
        control.configure(
            items: [
                .init(image: ResourceKitAsset.volumeMute.image, title: "무음"),
                .init(image: ResourceKitAsset.music.image, title: "BGM"),
                .init(image: ResourceKitAsset.volume.image, title: "원본")
            ],
            initialIndex: Constants.initialSelectedSegmentIndex
        )
        return control
    }()

    private let selectedBGMLabel: UILabel = .init()

    let removeView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .red50
        view.isHidden = true
        return view
    }()

    private let removeSubview: UIView = .init()

    private let removeTopLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "이곳에 놓아서 삭제",
            font: .systemFont(ofSize: 16, weight: .medium),
            textColor: .red600,
            alignment: .center
        )
        return label
    }()

    private let removeBottomLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "\"B컷에도 소중한 이야기가 담겨있어요\"",
            font: .systemFont(ofSize: 14, weight: .regular),
            textColor: .neutral600,
            alignment: .center
        )
        return label
    }()

    private lazy var resetButton: UIButton = {
        let button: UIButton = .init()
        button.setAttributedTitle(
            .makeAttributedString(
                text: "리셋",
                font: .systemFont(ofSize: 16, weight: .regular),
                textColor: .red600,
                alignment: .center
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(self.resetButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture(_:)))
        gesture.minimumPressDuration = 0.5
        return gesture
    }()

    // MARK: - Properties

    weak var listener: VideoCreationPresentableListener?
    var pendingPlayer: AVPlayer?
    private var fillLayer: CALayer?
    var clips: [CompositionClip] = []
    private var lastIndex: Int = Constants.initialSelectedSegmentIndex

    // MARK: - Override func

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    override func setupUI() {
        super.setupUI()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.resetButton)

        self.view.addGestureRecognizer(self.longPressGestureRecognizer)
        self.view.addSubviews(self.totalView, self.removeView)
        self.totalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        self.removeView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(128)
        }

        self.totalView.addSubviews(self.contentsSubview, self.makeButton)
        self.contentsSubview.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualTo(self.makeButton.snp.top).offset(-32)
            $0.centerY.equalToSuperview().priority(.low)
        }
        self.makeButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }

        self.titleView.addSubviews(self.titleLabel, self.titleTextField)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.titleTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.contentsSubview.addSubviews(self.titleView, self.collectionView, self.segmentedControl, self.selectedBGMLabel)
        self.titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.titleView.snp.bottom).offset(Constants.contentViewSpacing)
            $0.leading.trailing.equalToSuperview()
        }
        self.segmentedControl.snp.makeConstraints {
            $0.top.equalTo(self.collectionView.snp.bottom).offset(Constants.contentViewSpacing)
            $0.centerX.equalToSuperview()
        }
        self.selectedBGMLabel.snp.makeConstraints {
            $0.top.equalTo(self.segmentedControl.snp.bottom).offset(Constants.contentViewSpacing)
            $0.centerX.bottom.equalToSuperview()
        }

        self.removeView.addSubview(self.removeSubview)
        self.removeSubview.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.removeSubview.addSubviews(self.removeTopLabel, self.removeBottomLabel)
        self.removeTopLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.removeBottomLabel.snp.makeConstraints {
            $0.top.equalTo(self.removeTopLabel.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.collectionView.dataSource = self.dataSource

        self.view.addInteraction(UIDropInteraction(delegate: self))
    }

    override func bind() {
        super.bind()

        self.viewDidLoadPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.initClips()
            })
            .store(in: &self.cancellables)

        self.listener?.clipsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] clips in
                guard let self else { return }
                self.clips = clips
                self.applySnapshot()
            })
            .store(in: &self.cancellables)

        self.listener?.selectedBGMPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bgm in
                guard let self, let bgm else { return }
                self.selectedBGMLabel.attributedText = .makeAttributedString(
                    text: "BGM - \(bgm.fileName)",
                    font: .systemFont(ofSize: 14, weight: .medium),
                    textColor: .neutral600,
                    alignment: .center
                )
                self.lastIndex = Constants.bgmIndex
                self.segmentedControl.selectSegment(at: Constants.bgmIndex)
            })
            .store(in: &self.cancellables)

        self.makeButton.publisher(for: .touchDown)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.startHoldAnimation()
            })
            .store(in: &cancellables)

        self.makeButton.publisher(for: [.touchUpInside, .touchUpOutside, .touchCancel])
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.endHoldAnimation()
            })
            .store(in: &cancellables)

        for button in self.segmentedControl.buttons {
            button.publisher(for: .touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    guard let self else { return }
                    if self.segmentedControl.selectedIndex == Constants.bgmIndex {
                        if self.selectedBGMLabel.attributedText == nil {
                            self.segmentedControl.selectSegment(at: self.lastIndex)
                        }
                        self.listener?.bgmSelectButtonTapped()
                    } else {
                        self.lastIndex = self.segmentedControl.selectedIndex
                    }
                })
                .store(in: &cancellables)
        }
    }
}

extension VideoCreationViewController {
    private func makeThumbnailView() -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 4
        return imageView
    }

    @objc private func resetButtonTapped() {
        // TODO: - 구현 예정
        print("pane_리셋버튼 탭")
    }
}

extension VideoCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension VideoCreationViewController: CAAnimationDelegate {
    func animationDidStop(_: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        self.longPressDidComplete()
    }

    private func startHoldAnimation() {
        self.fillLayer?.removeFromSuperlayer()

        let layer = CALayer()
        layer.backgroundColor = UIColor.neutral800.cgColor
        layer.anchorPoint = .zero
        layer.frame = CGRect(x: 0, y: 0, width: 0, height: self.makeButton.bounds.height)

        self.makeButton.layer.insertSublayer(layer, at: 0)
        self.fillLayer = layer
        self.makeButton.layoutIfNeeded()

        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = 0
        animation.toValue = self.makeButton.bounds.width
        animation.duration = Constants.makeButtonDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        layer.add(animation, forKey: "fillWidth")
    }

    private func endHoldAnimation() {
        self.fillLayer?.removeAllAnimations()
        UIView.animate(withDuration: 0.2) {
            self.fillLayer?.bounds.size.width = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            self.fillLayer?.removeFromSuperlayer()
        }
    }

    private func longPressDidComplete() {
        // TODO: - 구현 예정
        print("완료")
    }

    private func applySnapshot() {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CompositionClip>()
        snapShot.appendSections([.main])
        snapShot.appendItems(self.clips, toSection: .main)
        self.dataSource.apply(snapShot, animatingDifferences: true)
    }

    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let locationInCollection = gesture.location(in: self.collectionView)
        switch gesture.state {
        case .began:
            if let _ = collectionView.indexPathForItem(at: locationInCollection) {
                self.removeView.isHidden = false
            }

        case .ended, .cancelled:
            let locationInView = gesture.location(in: self.view)
            if !self.removeView.isHidden,
               self.removeView.frame.contains(locationInView),
               let indexPath = collectionView.indexPathForItem(at: locationInCollection) {
                let clip = self.clips[indexPath.item]
                self.listener?.delete(clip: clip)
            }
            self.removeView.isHidden = true

        default:
            break
        }
    }
}
