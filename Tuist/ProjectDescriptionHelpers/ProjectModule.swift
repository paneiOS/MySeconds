//
//  ProjectModule.swift
//  ProjectDescriptionHelpers
//
//  Created by 이정환 on 7/12/25.
//

import ProjectDescription

// MARK: - ModuleConvertible Protocol

public protocol ModuleConvertible: RawRepresentable where RawValue == String {
    var group: Modules.Group { get }
}

public extension ModuleConvertible {
    var module: Modules.Module {
        Modules.Module(group: group, name: self.rawValue)
    }

    var dependency: TargetDependency {
        self.module.dependency
    }

    var target: TargetDependency {
        self.module.target
    }
}

// MARK: - Modules

public enum Modules {
    public enum Group: String {
        case main = "Main"
        case shared = "Shared"
        case features = "Features"
        case services = "Services"
    }
}

public extension Modules {
    struct Module {
        public let group: Group
        public let name: String

        var path: Path {
            switch self.group {
            case .main:
                .relativeToRoot("MySeconds")
            default:
                .relativeToRoot("MySeconds/\(self.group.rawValue)/\(self.name)")
            }
        }

        public var dependency: TargetDependency {
            .project(target: self.name, path: self.path)
        }

        public var target: TargetDependency {
            .target(name: self.name)
        }

        public var bundleID: String {
            "com.panestudio." + self.name
        }

        public var sampleAppName: String {
            self.name + "ModuleApp"
        }

        public var sampleBundleID: String {
            self.bundleID + "ModuleApp"
        }

        public var testAppName: String {
            self.name + "Tests"
        }

        public var testBundleID: String {
            self.bundleID + "Tests"
        }
    }
}

// MARK: - Group

public extension Modules {
    enum App: String, ModuleConvertible {
        case main = "MySeconds"

        public var group: Modules.Group { .main }
    }

    enum Shared: String, ModuleConvertible {
        case mySecondsShared = "MySecondsShared"
        case utilsKit = "UtilsKit"
        case resourceKit = "ResourceKit"
        case baseRIBsKit = "BaseRIBsKit"
        case componentsKit = "ComponentsKit"
        case sharedModels = "SharedModels"

        public var group: Modules.Group { .shared }
    }

    enum Features: String, ModuleConvertible {
        case login = "Login"
        case signUp = "SignUp"
        case videoRecord = "VideoRecord"
        case videoCreation = "VideoCreation"
        case coverClipCreation = "CoverClipCreation"
        case bgmSelect = "BGMSelect"

        public var group: Modules.Group { .features }
    }

    enum Services: String, ModuleConvertible {
        case socialLoginKit = "SocialLoginKit"
        case videoDraftStorage = "VideoDraftStorage"
        case videoRecordingManager = "VideoRecordingManager"

        public var group: Modules.Group { .services }
    }
}
