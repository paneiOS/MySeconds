//
//  Project.swift
//  MySeconds
//
//  Created by pane on 07/13/2025.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "MySeconds",
    options: .options(automaticSchemesOptions: .disabled),
    targets: [
        .target(
            name: "MySeconds",
            destinations: .iOS,
            product: .app,
            bundleId: "com.panestudio.myseconds",
            deploymentTargets: .iOS("17.0"),
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
                    "UIApplicationMainStoryboardFile": "",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["com.googleusercontent.apps.120605294852-s7fhvg2713civjkojb7utjjbnsa7apmt"]
                        ]
                    ],
                    "NSCameraUsageDescription": "영상 촬영을 위해 카메라 접근 권한이 필요합니다.",
                    "NSMicrophoneUsageDescription": "영상 녹화 중 음성을 녹음하기 위해 마이크 접근 권한이 필요합니다."
                ]
            ),
            sources: ["MySeconds/Sources/**"],
            resources: [
                "MySeconds/Resources/**",
                "MySeconds/Resources/GoogleService-Info.plist",
                .folderReference(path: "MySeconds/Shared/ResourceKit/Resources/Fonts")
            ],
            entitlements: "MySeconds.entitlements",
            scripts: [
                .pre(
                    script: """
                    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
                    swiftlint lint --config "${SRCROOT}/.swiftlint.yml" --reporter xcode
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
                Modules.Features.bgmSelect.dependency,
                Modules.Features.login.dependency,
                Modules.Features.signUp.dependency,
                Modules.Features.videoRecord.dependency
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds"
                ]
            )
        )
    ],
    schemes: [
        .scheme(
            name: "MySeconds",
            shared: true,
            buildAction: .buildAction(targets: ["MySeconds"]),
            runAction: .runAction(executable: "MySeconds")
        )
    ]
)
