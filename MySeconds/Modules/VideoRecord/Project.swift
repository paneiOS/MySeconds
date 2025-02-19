//
//  Project.swift
//  MySeconds
//
//  Created by chungwussup on 02/18/2025.
//

import ProjectDescription

let project = Project(
    name: "VideoRecord",
    targets: [
        .target(
            name: "VideoRecord",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.videorecord",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .package(product: "ModernRIBs", type: .runtime),
                .package(product: "SnapKit", type: .runtime)
            ]
        ),
        .target(
            name: "VideoRecordModuleApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.panestudio.VideoRecordModleApp",
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
                .target(name: "VideoRecord")
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
            name: "VideoRecordTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.panestudio.videorecord",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "VideoRecord")
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
