//
//  Project.swift
//  MySeconds
//
//  Created by pane on 07/13/2025.
//

import ProjectDescription
import ProjectDescriptionHelpers

nonisolated(unsafe) let module = Modules.Shared.resourceKit.module
let project = Project(
    name: module.name,
    targets: [
        .target(
            name: module.name,
            destinations: .iOS,
            product: .framework,
            bundleId: module.bundleID,
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [
                .folderReference(path: "Resources/BGMs"),
                .glob(pattern: "Resources/**", excluding: ["Resources/BGMs/**"])
            ],
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
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds"
                ]
            )
        )
    ]
)
