//
//  Project.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import ProjectDescription

let project = Project(
    name: "SharedModels",
    targets: [
        .target(
            name: "SharedModels",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.SharedModels",
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
            dependencies: []
        )
    ]
)
