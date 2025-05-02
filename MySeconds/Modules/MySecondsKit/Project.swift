//
//  Project.swift
//  MySeconds
//
//  Created by hh647 on 01/27/2025.
//

import ProjectDescription

let project = Project(
    name: "MySecondsKit",
    targets: [
        .target(
            name: "MySecondsKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.mysecondskit",
            infoPlist: .default,
            sources: ["Sources/**"],
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
                .external(name: "SnapKit"),
                .project(target: "ResourceKit", path: "../ResourceKit"),
                .project(target: "UtilsKit", path: "../UtilsKit")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds"
                ]
            )
        )
    ]
)
