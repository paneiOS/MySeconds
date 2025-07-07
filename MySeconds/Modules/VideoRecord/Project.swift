//
//  Project.swift
//  MySeconds
//
//  Created by chungwussup on 05/19/2025.
//

import ProjectDescription

let project = Project(
    name: "VideoRecord",
    targets: [
        .target(
            name: "VideoRecord",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.VideoRecord",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .external(name: "SnapKit"),
                .project(target: "BaseRIBsKit", path: "../BaseRIBsKit"),
                .project(target: "MySecondsKit", path: "../MySecondsKit"),
                .project(target: "ResourceKit", path: "../ResourceKit"),
                .project(target: "VideoDraftStorage", path: "../../Core/VideoDraftStorage"),
                .project(target: "VideoRecordingManager", path: "../../Core/VideoRecordingManager"),
                .project(target: "UtilsKit", path: "../UtilsKit")
            ]
        ),
        .target(
            name: "VideoRecordModuleApp",
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
                    ],
                    "NSCameraUsageDescription": "영상 촬영을 위해 카메라 접근 권한이 필요합니다.",
                    "NSMicrophoneUsageDescription": "영상 녹화 중 음성을 녹음하기 위해 마이크 접근 권한이 필요합니다."
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
