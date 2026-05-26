//
//  AppRouter.swift
//  ExchangeCalculator
//
//  Created by Антон Петренко on 23/05/2026.
//

import SwiftUI
import Combine
import Utilities
import ExchangeFeature

@MainActor
final class AppRouter: ObservableObject {

    @Published var navigationPath: NavigationPath
    private let resolver: Resolver

    private(set) lazy var initialView: AnyView = resolveInitialRouter().makeView()

    init(
        navigationPath: NavigationPath = NavigationPath(),
        resolver: Resolver
    ) {
        self.navigationPath = navigationPath
        self.resolver = resolver
    }

    private func resolveInitialRouter() -> any Routable {
        ExchangePageRouter(rootCoordinator: self, resolver: resolver)
    }
}

extension AppRouter: NavigationCoordinator {
    func push(_ router: any Routable) {
        let wrappedRouter = AnyRoutable(router)
        self.navigationPath.append(wrappedRouter)
    }

    func popLast() {
        guard navigationPath.count > 1 else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath.removeLast(self.navigationPath.count)
    }

}
