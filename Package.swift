// swift-tools-version:5.7
//
//  Package.swift
//  LoginManifests
//
//  Created by 이정환 on 4/29/25.
//

@preconcurrency import PackageDescription

let package = Package(
    name: "MySeconds",
    platforms: [
        .iOS(.v15)
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/DevYeom/ModernRIBs.git", from: "1.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0")
    ]
)
