//
//  Project.swift
//  MySeconds
//
//  Created by pane on 04/29/2025.
//

import ProjectDescription

let project = Project(
    name: "VideoCreation",
    targets: [
        .target(
            name: "VideoCreation",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.VideoCreation",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .external(name: "SnapKit"),
                .project(target: "BaseRIBsKit", path: "../BaseRIBsKit"),
                .project(target: "CoverClipCreation", path: "../CoverClipCreation"),
                .project(target: "MySecondsKit", path: "../MySecondsKit"),
                .project(target: "ResourceKit", path: "../ResourceKit"),
                .project(target: "SharedModels", path: "../../Core/SharedModels"),
                .project(target: "UtilsKit", path: "../UtilsKit")
            ]
        ),
        .target(
            name: "VideoCreationModuleApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.panestudio.myseconds",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ]
                            ]
                        ]
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["com.googleusercontent.apps.120605294852-s7fhvg2713civjkojb7utjjbnsa7apmt"]
                        ]
                    ]
                ]
            ),
            sources: ["AppSources/**"],
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
                .target(name: "VideoCreation")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds"
                ]
            )
        ),
        .target(
            name: "VideoCreationTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.panestudio.videocreation",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "VideoCreation")
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
