//
//  Feature.swift
//  Templates
//
//  Created by 이정환 on 1/3/25.
//

import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
    description: "Creates a new feature module",
    attributes: [
        nameAttribute
    ],
    items: [
        .file(
            path: "Modules/\(nameAttribute)/Project.swift",
            templatePath: "Project.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Sources/\(nameAttribute).swift",
            templatePath: "Feature.stencil"
        )
    ]
)
