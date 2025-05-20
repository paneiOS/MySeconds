//
//  Project.swift
//  MySeconds
//
//  Created by pane on 05/15/2025.
//

import ProjectDescription

let project = Project(
    name: "CoverClipCreation",
    targets: [
        .target(
            name: "CoverClipCreation",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.CoverClipCreation",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .external(name: "SnapKit"),
                .project(target: "BaseRIBsKit", path: "../BaseRIBsKit"),
                .project(target: "MySecondsKit", path: "../MySecondsKit"),
                .project(target: "ResourceKit", path: "../ResourceKit"),
                .project(target: "UtilsKit", path: "../UtilsKit")
            ]
        ),
        .target(
            name: "CoverClipCreationModuleApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.panestudio.myseconds",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIAppFonts": [
                        "Fonts/DungGeunMo.ttf",
                        "Fonts/Inklipquid.otf",
                        "Fonts/Samulnori-Medium.otf",
                        "Fonts/ParkDaHyun.ttf",
                        "Fonts/YClover-Regular.otf"
                    ],
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
            resources: [.folderReference(path: "../ResourceKit/Resources/Fonts")],
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
                .target(name: "CoverClipCreation")
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
            name: "CoverClipCreationTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.panestudio.coverclipcreation",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "CoverClipCreation")
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
