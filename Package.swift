// swift-tools-version:5.9
//
//  Package.swift
//  LoginManifests
//
//  Created by 이정환 on 4/29/25.
//

@preconcurrency import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "SnapKit": .framework,
            "ModernRIBs": .framework
        ]
    )
#endif

let package = Package(
    name: "MySecondsDependencies",
    platforms: [
        .iOS(.v15)
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.6.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0"),
        .package(url: "https://github.com/DevYeom/ModernRIBs.git", from: "1.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0")
    ]
)
