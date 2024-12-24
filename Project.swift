import ProjectDescription

let project = Project(
    name: "MySeconds",
    targets: [
        .target(
            name: "MySeconds",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.MySeconds",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["MySeconds/Sources/**"],
            resources: ["MySeconds/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "MySecondsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.MySecondsTests",
            infoPlist: .default,
            sources: ["MySeconds/Tests/**"],
            resources: [],
            dependencies: [.target(name: "MySeconds")]
        ),
    ]
)
