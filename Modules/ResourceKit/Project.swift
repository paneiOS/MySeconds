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
            resources: [],
            dependencies: []
        )
    ]
)
