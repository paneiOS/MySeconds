//
//  BGMSelectViewController.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import Combine
import UIKit

import BaseRIBsKit
import ComponentsKit

protocol BGMSelectPresentableListener: AnyObject {
    var bgmListPublisher: AnyPublisher<[BGM], Never> { get }
    var currentTimePublisher: AnyPublisher<TimeInterval, Never> { get }
    func initData()
    func play(bgm: BGM)
    func stop()
    func applyButtonTapped(bgm: BGM)
    func closeButtonTapped()
}

final class BGMSelectViewController: BaseBottomSheetViewController, BGMSelectPresentable, BGMSelectViewControllable {
    private enum Constants {
        static let viewHeight: CGFloat = UIScreen.main.bounds.height * 420.0 / 852.0
    }

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 56)
        layout.sectionInset = .zero
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        let view: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.allowsSelection = false
        view.register(BGMCell.self, forCellWithReuseIdentifier: BGMCell.reuseIdentifier)
        view.dataSource = self
        return view
    }()

    // MARK: - Properties

    weak var listener: BGMSelectPresentableListener?
    private var bgmList: [BGM] = []
    private var playingIndexPath: IndexPath?

    // MARK: - Override func

    override func setupUI() {
        super.setupUI()

        self.headerLabel.attributedText = .makeAttributedString(
            text: "BGM 선택",
            font: .systemFont(ofSize: 20, weight: .bold),
            letterSpacingPercentage: -0.45
        )
        self.sheetContainerView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(Constants.viewHeight)
        }
    }

    override func bind() {
        super.bind()

        self.viewDidLoadPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.initData()
            })
            .store(in: &self.cancellables)

        self.closeTappedPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.listener?.stop()
                self.listener?.closeButtonTapped()
            })
            .store(in: &self.cancellables)

        if let listener {
            listener.bgmListPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] bgmList in
                    guard let self else { return }
                    self.bgmList = bgmList
                    self.collectionView.reloadData()
                })
                .store(in: &self.cancellables)

            listener.currentTimePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] time in
                    guard let self,
                          let indexPath = self.playingIndexPath,
                          let cell = self.collectionView.cellForItem(at: indexPath) as? BGMCell else {
                        return
                    }
                    cell.updatePlayTime(time)
                })
                .store(in: &self.cancellables)
        }
    }
}

extension BGMSelectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.bgmList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let bgm = self.bgmList[safe: indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BGMCell.reuseIdentifier, for: indexPath) as? BGMCell else {
            return UICollectionViewCell()
        }
        cell.drawCell(model: bgm)
        cell.isPlay = indexPath == self.playingIndexPath

        cell.playPulbisher.sink(receiveValue: { [weak self] isPlay in
            guard let self, let bgm = self.bgmList[safe: indexPath.item] else { return }
            if isPlay {
                if let prevIndexPath = self.playingIndexPath,
                   let prevCell = self.collectionView.cellForItem(at: prevIndexPath) as? BGMCell,
                   prevIndexPath != indexPath {
                    prevCell.isPlay = false
                }
                self.playingIndexPath = indexPath
                self.listener?.play(bgm: bgm)
            } else {
                self.playingIndexPath = nil
                self.listener?.stop()
            }
        })
        .store(in: &self.cancellables)

        cell.applyPublisher.sink(receiveValue: { [weak self] _ in
            guard let self, let bgm = self.bgmList[safe: indexPath.item] else { return }
            self.listener?.applyButtonTapped(bgm: bgm)
        })
        .store(in: &self.cancellables)
        return cell
    }
}
