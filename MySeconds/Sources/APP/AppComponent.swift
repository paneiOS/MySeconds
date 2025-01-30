//
//  AppComponent.swift
//  MySeconds
//
//  Created by JeongHwan Lee on 1/29/25.
//

import ModernRIBs

final class AppComponent: Component<EmptyDependency>, RootDependency {
    init() {
        super.init(dependency: EmptyComponent())
    }
}
