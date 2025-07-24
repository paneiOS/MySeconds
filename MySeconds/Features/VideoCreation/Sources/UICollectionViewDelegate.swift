//
//  UICollectionViewDelegate.swift
//  VideoCreation
//
//  Created by 이정환 on 7/13/25.
//

import AVKit
import UIKit

import ComponentsKit
import SharedModels

extension VideoCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let clip = clips[safe: indexPath.item], let listener else { return }
        switch clip {
        case let .cover(coverClip):
            listener.didSelectCoverClip(clip: coverClip)
        case let .video(videoClip):
            let player = AVPlayer(url: videoClip.filePath(directoryURL: listener.directoryURL))
            self.pendingPlayer = player
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.modalPresentationStyle = .custom
            playerViewController.transitioningDelegate = self
            player.play()
            self.present(playerViewController, animated: true, completion: nil)
        }
    }
}

extension VideoCreationViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        self.removeView.isHidden = false
        guard let clip = clips[safe: indexPath.item] else { return [] }
        switch clip {
        case let .video(videoClip):
            let itemProvider = NSItemProvider(object: videoClip.fileName as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = clip
            return [dragItem]
        case .cover:
            return []
        }
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let bounds = collectionView.cellForItem(at: indexPath)?.bounds else { return nil }
        let params = UIDragPreviewParameters()
        params.visiblePath = UIBezierPath(roundedRect: bounds, cornerRadius: 8)
        params.backgroundColor = .clear
        return params
    }
}

extension VideoCreationViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        session.localDragSession != nil
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let index = destinationIndexPath?.item else {
            return .init(operation: .cancel)
        }
        if index > 0, index < (self.clips.count - 1) {
            return .init(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return .init(operation: .forbidden)
        }
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        self.removeView.isHidden = true
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnter session: UIDropSession) {
        self.removeView.isHidden = false
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        self.longPressGestureRecognizer.isEnabled = false
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        self.longPressGestureRecognizer.isEnabled = true
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destination = coordinator.destinationIndexPath else { return }
        for item in coordinator.items {
            guard let src = item.sourceIndexPath else { continue }
            let clip = self.clips.remove(at: src.item)
            self.clips.insert(clip, at: destination.item)
            var snap = self.dataSource.snapshot()
            snap.deleteAllItems()
            snap.appendSections([.main])
            snap.appendItems(self.clips, toSection: .main)
            self.dataSource.apply(snap, animatingDifferences: true)
            coordinator.drop(item.dragItem, toItemAt: destination)
            self.listener?.updateClips(self.clips)
        }
        self.removeView.isHidden = true
    }
}

extension VideoCreationViewController: UIDropInteractionDelegate {
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let locationView = session.location(in: self.view)
        if self.removeView.frame.contains(locationView) {
            return UIDropProposal(operation: .move)
        }

        return UIDropProposal(operation: .forbidden)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if self.removeView.frame.contains(session.location(in: view)) {
            guard let clip = session.items.first?.localObject as? CompositionClip else { return }
            self.listener?.deleteClip(clip)
            self.removeView.isHidden = true
        }
    }
}

extension VideoCreationViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let idx = collectionView.indexPathsForSelectedItems?.first,
              let player = pendingPlayer,
              let container = presenting.view.window,
              let cell = self.collectionView.cellForItem(at: idx) else {
            return nil
        }
        let origin = cell.contentView.convert(cell.contentView.bounds, to: container)
        return PlayerZoomTransition(frame: origin, player: player, duration: 0.4)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        FadeOutTransition(duration: 0.2)
    }
}
