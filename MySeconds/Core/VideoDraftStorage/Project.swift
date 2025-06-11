//
//  Project.swift
//  MySeconds
//
//  Created by pane on 06/05/2025.
//

import ProjectDescription

let project = Project(
    name: "VideoDraftStorage",
    targets: [
        .target(
            name: "VideoDraftStorage",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.VideoDraftStorage",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            scripts: [
                .pre(
                    script: """
                    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
                    swiftlint lint --config "../../../.swiftlint.yml"
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
                .project(target: "UtilsKit", path: "../../Modules/UtilsKit")
            ]
        ),
        .target(
            name: "VideoDraftStorageTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.panestudio.VideoDraftStorage",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "VideoDraftStorage")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds"
                ]
            )
        )
    ],
    schemes: [
        .scheme(
            name: "VideoDraftStorageTests",
            shared: true,
            buildAction: .buildAction(targets: ["VideoDraftStorage", "VideoDraftStorageTests"]),
            testAction: .targets(["VideoDraftStorageTests"]),
            runAction: nil
        )
    ]
)
