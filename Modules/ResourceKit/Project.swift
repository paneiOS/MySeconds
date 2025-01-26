import ProjectDescription

let project = Project(
    name: "ResourceKit",
    targets: [
        .target(
            name: "ResourceKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.resourcekit",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [
                .pre(
                    script: """
                    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
                    swiftlint lint --reporter xcode
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
            dependencies: []
        )
    ]
)
