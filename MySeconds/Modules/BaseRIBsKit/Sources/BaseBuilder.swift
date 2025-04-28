//
//  BaseBuilder.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import ModernRIBs

open class BaseBuilder<DependencyType: Dependency>: Builder<DependencyType> {

    override public init(dependency: DependencyType) {
        super.init(dependency: dependency)
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }
}
