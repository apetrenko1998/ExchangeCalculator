//
//  ExchangePageRouter.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 23/05/2026.
//

import SwiftUI
import Utilities

@MainActor
public class ExchangePageRouter {
    private let id: UUID = .init()
    private let rootCoordinator: NavigationCoordinator
    private let resolver: Resolver
    
    public init(
        rootCoordinator: NavigationCoordinator,
        resolver: Resolver
    ) {
        self.rootCoordinator = rootCoordinator
        self.resolver = resolver
    }
    
    // here could be methods for navigation to other screens by pushing another router
}

extension ExchangePageRouter: Routable {
    public func makeView() -> AnyView {
        let viewModel = ExchangeViewModel(
            currenciesUseCase: resolver.resolveDependency(),
            exchangeRatesUseCase: resolver.resolveDependency(),
            currencyConversionUseCase: resolver.resolveDependency(),
            currencyPresentationMapper: resolver.resolveDependency()
        )
        return AnyView(ExchangeCalculatorView(viewModel: viewModel))
    }
}

extension ExchangePageRouter {
    public nonisolated static func == (lhs: ExchangePageRouter, rhs: ExchangePageRouter) -> Bool {
        lhs.id == rhs.id
    }
    
    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
