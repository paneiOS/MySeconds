//
//  NavigationOptionProvidable.swift
//  SharedModels
//
//  Created by 이정환 on 7/11/25.
//

import ObjectiveC.runtime
import UIKit

public enum NavigationOption {
    case showsNavigationBar
    case hidesNavigationBar
}

public protocol NavigationOptionProvidable {
    var navigationOptions: [NavigationOption] { get }
}

private var navigationOptionKey: UInt8 = 0

public extension UIViewController {
    var navigationOption: NavigationOption? {
        get {
            objc_getAssociatedObject(self, &navigationOptionKey) as? NavigationOption
        }
        set {
            objc_setAssociatedObject(self, &navigationOptionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
