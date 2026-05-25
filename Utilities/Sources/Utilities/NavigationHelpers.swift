//
//  NavigationHelpers.swift
//  Utilities
//
//  Created by Антон Петренко on 23/05/2026.
//

import SwiftUI

public protocol ViewFactory {
    @MainActor func makeView() -> AnyView
}

public typealias Routable = ViewFactory & Hashable

public protocol NavigationCoordinator {
    func push(_ router: any Routable)
    func popLast()
    func popToRoot()
}
