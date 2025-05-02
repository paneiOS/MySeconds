//
//  feature.swift
//  MySeconds
//
//  Created by 이정환 on 1/3/25.
//

import Foundation

import ProjectDescription

private let currentDate: String = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: Date())
}()

private let userName: String = NSUserName()

private let nameAttribute: Template.Attribute = .required("name")

let featureTemplate = Template(
    description: "Creates a new feature module",
    attributes: [
        nameAttribute,
        .optional("userName", default: .string(userName)),
        .optional("date", default: .string(currentDate))
    ],
    items: [
        .file(
            path: "MySeconds/Modules/\(nameAttribute)/Project.swift",
            templatePath: "stencils/Project.stencil"
        ),
        .file(
            path: "MySeconds/Modules/\(nameAttribute)/Sources/\(nameAttribute).swift",
            templatePath: "stencils/Feature.stencil"
        )
    ]
)
