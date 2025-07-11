//
//  Project.swift
//  MySeconds
//
//  Created by chungwussup on 06/25/2025.
//

import ProjectDescription

let project = Project(
    name: "VideoRecordingManager",
    targets: [
        .target(
            name: "VideoRecordingManager",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.VideoRecordingManager",
            deploymentTargets: .iOS("17.0"),
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
                .project(target: "SharedModels", path: "../../Core/SharedModels")
            ]
        )
    ]
)
