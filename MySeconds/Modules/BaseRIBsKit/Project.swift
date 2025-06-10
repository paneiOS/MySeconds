//
//  Project.swift
//  MySeconds
//
//  Created by pane on 04/22/2025.
//

import ProjectDescription

let project = Project(
    name: "BaseRIBsKit",
    targets: [
        .target(
            name: "BaseRIBsKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.panestudio.baseribskit",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .external(name: "ModernRIBs")
            ]
        )
    ]
)
