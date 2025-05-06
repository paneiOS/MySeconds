//
//  UICollectionView+.swift
//  UtilsKit
//
//  Created by 이정환 on 5/5/25.
//

import UIKit

public protocol ReusableCell: AnyObject {
    static var reuseIdentifier: String { get }
}

public extension ReusableCell {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UICollectionViewCell: ReusableCell {}

public extension UICollectionView {
    func dequeueReusableCell<T: ReusableCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        let id = cellType.reuseIdentifier
        guard let cell = dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as? T else {
            preconditionFailure("❌ 셀 dequeue 실패: \(id) 가 등록되지 않았거나 잘못된 타입입니다.")
        }
        return cell
    }
}
