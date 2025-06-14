//
//  Project.swift
//  MySeconds
//
//  Created by pane on 6/12/25.
//

import ProjectDescription

let project = Project(
    name: "SocialLoginKit",
    targets: [
        .target(
            name: "SocialLoginKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.SocialLoginKit",
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
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "GoogleSignIn")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds",
                    "OTHER_LDFLAGS": "$(inherited) -ObjC"
                ]
            )
        )
    ]
)
