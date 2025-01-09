//
//  Project.swift
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
                .package(product: "FirebaseAuth", type: .runtime),
                .package(product: "ModernRIBs", type: .runtime),
                .package(product: "SnapKit", type: .runtime)
            ]
        ),
        .target(
            name: "LoginModuleApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.panestudio.LoginModleApp",
            infoPlist: .default,
            sources: ["AppSources/**"],
            scripts: [
                .pre(
                    script: """
                    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
                    swiftlint lint --reporter xcode
                    """,
                    name: "SwiftLint",
                    basedOnDependencyAnalysis: false
                ),
                .pre(
                    script: """
                    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
                    swiftformat .
                    """,
                    name: "SwiftFormat",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .target(name: "Login")
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
