//
//  Project.swift
//  MySeconds
//
//  Created by hh647 on 01/26/2025.
//

import ProjectDescription

let project = Project(
    name: "UtilsKit",
    targets: [
        .target(
            name: "UtilsKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.utilskit",
            deploymentTargets: .iOS("17.0"),
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
            dependencies: [],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds",
                    "DEFINES_MODULE": "YES",
                    "SWIFT_INSTALL_OBJC_HEADER": "YES"
                ]
            )
        )
    ]
)
