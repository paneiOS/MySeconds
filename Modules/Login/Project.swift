//
//  LoginProject.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import ProjectDescription

let project = Project(
    name: "Login",
    targets: [
        .target(
            name: "Login",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.login",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .package(product: "ModernRIBs", type: .runtime),
                .package(product: "SnapKit", type: .runtime)
            ]
        ),
        .target(
            name: "LoginTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.panestudio.login",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "Login")]
        )
    ]
)

