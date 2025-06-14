//
//  SignUpBuilder.swift
//  MySeconds
//
//  Created by pane on 04/23/2025.
//

import ModernRIBs

public protocol SignUpDependency: Dependency {}

public final class SignUpComponent: Component<SignUpDependency> {
    public let uid: String

    public init(dependency: SignUpDependency, uid: String) {
        self.uid = uid
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

public protocol SignUpBuildable: Buildable {
    func build(withListener listener: SignUpListener, uid: String) -> SignUpRouting
}

public final class SignUpBuilder: Builder<SignUpDependency>, SignUpBuildable {

    override public init(dependency: SignUpDependency) {
        super.init(dependency: dependency)
    }

    deinit {
        #if DEBUG
            print("✅ Deinit: \(self)")
        #endif
    }

    public func build(withListener listener: SignUpListener, uid: String) -> SignUpRouting {
        let component = SignUpComponent(dependency: dependency, uid: uid)
        let viewController = SignUpViewController()
        let interactor = SignUpInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return SignUpRouter(interactor: interactor, viewController: viewController)
    }
}
