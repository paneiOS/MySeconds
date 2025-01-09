//
//  feature.swift
//  MySeconds
//
//  Created by 이정환 on 1/3/25.
//

import Foundation

import ProjectDescription

let currentDate: String = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: Date())
}()

let userName: String = NSUserName()

let nameAttribute: Template.Attribute = .required("name")

let featureTemplate = Template(
    description: "Creates a new feature module",
    attributes: [
        nameAttribute,
        .optional("userName", default: .string(userName)),
        .optional("date", default: .string(currentDate))
    ],
    items: [
        .file(
            path: "Modules/\(nameAttribute)/Project.swift",
            templatePath: "stencils/Project.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Sources/\(nameAttribute).swift",
            templatePath: "stencils/Feature.stencil"
        )
    ]
)
