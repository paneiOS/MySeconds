//
//  Project.swift
//  MySeconds
//
//  Created by pane on 05/28/2025.
//

import ProjectDescription
import ProjectDescriptionHelpers

nonisolated(unsafe) let module = Modules.Features.bgmSelect.module
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
            resources: [],
            dependencies: [
                .external(name: "SnapKit"),
                Modules.Shared.baseRIBsKit.dependency,
                Modules.Shared.componentsKit.dependency
            ]
        ),
        .target(
            name: module.sampleAppName,
            destinations: .iOS,
            product: .app,
            bundleId: module.sampleBundleID,
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
                module.target
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
            name: "SignUpApp",
            shared: true,
            hidden: true,
            buildAction: .buildAction(targets: ["SignUpModuleApp"]),
            runAction: .runAction(executable: "SignUpModuleApp")
        )
    ]
)
