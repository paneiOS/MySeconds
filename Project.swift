import ProjectDescription

let project = Project(
    name: "MySeconds",
    packages: [],
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
                    ]
                ]
            ),
            sources: ["MySeconds/Sources/**"],
            resources: [
                "MySeconds/Resources/**",
                "MySeconds/Resources/GoogleService-Info.plist"
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
                .project(target: "SharedModels", path: "MySeconds/Core/SharedModels"),
                .project(target: "VideoDraftStorage", path: "MySeconds/Core/VideoDraftStorage"),

                .project(target: "BaseRIBsKit", path: "MySeconds/Modules/BaseRIBsKit"),
                .project(target: "MySecondsKit", path: "MySeconds/Modules/MySecondsKit"),
                .project(target: "ResourceKit", path: "MySeconds/Modules/ResourceKit"),
                .project(target: "UtilsKit", path: "MySeconds/Modules/UtilsKit"),
                .project(target: "BGMSelect", path: "MySeconds/Modules/BGMSelect"),
                .project(target: "CoverClipCreation", path: "MySeconds/Modules/CoverClipCreation"),
                .project(target: "Login", path: "MySeconds/Modules/Login"),
                .project(target: "SignUp", path: "MySeconds/Modules/SignUp"),
                .project(target: "VideoCreation", path: "MySeconds/Modules/VideoCreation"),
                .project(target: "VideoRecord", path: "MySeconds/Modules/VideoRecord")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds"
                ]
            )
        ),
        .target(
            name: "MySecondsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.panestudio.myseconds",
            infoPlist: .default,
            sources: ["MySeconds/Tests/**"],
            resources: [],
            dependencies: [.target(name: "MySeconds")],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "DEVELOPMENT_TEAM": "CB95NTZJ5Z",
                    "PROVISIONING_PROFILE_SPECIFIER": "MySeconds"
                ]
            )
        )
    ]
)
