//
//  Project.swift
//  MySeconds
//
//  Created by pane on 06/05/2025.
//

import ProjectDescription
import ProjectDescriptionHelpers

nonisolated(unsafe) let module = Modules.Services.videoDraftStorage.module
let project = Project(
    name: module.name,
    targets: [
        .target(
            name: module.name,
            destinations: .iOS,
            product: .framework,
            bundleId: module.bundleID,
            deploymentTargets: .iOS("17.0"),
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
                Modules.Shared.sharedModels.dependency,
                Modules.Shared.utilsKit.dependency
            ]
        ),
        .target(
            name: module.testAppName,
            destinations: .iOS,
            product: .unitTests,
            bundleId: module.testBundleID,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                module.target
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
            name: module.name,
            shared: true,
            hidden: true,
            buildAction: .buildAction(targets: ["\(module.name)", "\(module.testAppName)"]),
            testAction: .targets(["\(module.testAppName)"]),
            runAction: nil
        )
    ]
)
