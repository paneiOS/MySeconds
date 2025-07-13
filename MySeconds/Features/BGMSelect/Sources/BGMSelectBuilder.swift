//
//  BGMSelectBuilder.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import AVFoundation

import ModernRIBs

import BaseRIBsKit
import ResourceKit

public protocol BGMSelectDependency: Dependency {}

public final class BGMSelectComponent: Component<BGMSelectDependency> {
    public let bgmDirectoryURL: URL

    public init(dependency: BGMSelectDependency, bgmDirectoryURL: URL) {
        self.bgmDirectoryURL = bgmDirectoryURL
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol BGMSelectBuildable: Buildable {
    func build(withListener listener: BGMSelectListener, bgmDirectoryURL: URL) -> BGMSelectRouting
}

public final class BGMSelectBuilder: Builder<BGMSelectDependency>, BGMSelectBuildable {

    override public init(dependency: BGMSelectDependency) {
        super.init(dependency: dependency)
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }

    public func build(withListener listener: BGMSelectListener, bgmDirectoryURL: URL) -> BGMSelectRouting {
        let component = BGMSelectComponent(dependency: dependency, bgmDirectoryURL: bgmDirectoryURL)
        let viewController = BGMSelectViewController()
        let interactor = BGMSelectInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return BGMSelectRouter(interactor: interactor, viewController: viewController)
    }
}
