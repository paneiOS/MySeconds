//
//  Dependencies.swift
//  MySecondsDependencies
//
//  Created by 이정환 on 4/29/25.
//

import Foundation

let dependencies = Dependencies(
  swiftPackageManager: .init(
    packages: [
      .local(path: "Tuist")
    ]
  ),
  platforms: [.iOS]
)
