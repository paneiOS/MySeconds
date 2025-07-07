//
//  Project.swift
//  MySeconds
//
//  Created by pane on 01/09/2025.
//

import ProjectDescription

let project = Project(
    name: "Login",
    options: .options(automaticSchemesOptions: .disabled),
    targets: [
        .target(
            name: "Login",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.login",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "BaseRIBsKit", path: "../BaseRIBsKit"),
                .project(target: "MySecondsKit", path: "../MySecondsKit"),
                .project(target: "ResourceKit", path: "../ResourceKit")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds",
                    "OTHER_LDFLAGS": "$(inherited) -ObjC"
                ]
            )
        ),
        .target(
            name: "LoginModuleApp",
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
            resources: ["../../../MySeconds/Resources/GoogleService-Info.plist"],
            entitlements: "../../../MySeconds.entitlements",
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
                .target(name: "Login")
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
    ],
    schemes: [
        .scheme(
            name: "LoginApp",
            shared: true,
            hidden: true,
            buildAction: .buildAction(targets: ["LoginModuleApp"]),
            runAction: .runAction(executable: "LoginModuleApp")
        )
    ]
)
