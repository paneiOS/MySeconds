//
//  ribs.swift
//  MySeconds
//
//  Created by 이정환 on 1/6/25.
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

let ribsTemplate = Template(
    description: "ModernRIBs ownsView 기반 RIB 생성",
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
            path: "Modules/\(nameAttribute)/Sources/\(nameAttribute)Builder.swift",
            templatePath: "stencils/Builder.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Sources/\(nameAttribute)Router.swift",
            templatePath: "stencils/Router.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Sources/\(nameAttribute)Interactor.swift",
            templatePath: "stencils/Interactor.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Sources/\(nameAttribute)ViewController.swift",
            templatePath: "stencils/ViewController.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift",
            templatePath: "stencils/Tests.stencil"
        )
    ]
)
