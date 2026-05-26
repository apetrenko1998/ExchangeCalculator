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
    
}

extension ExchangePageRouter: Routable {
    public func makeView() -> AnyView {
        do {
            let viewModel = ExchangeViewModel(
                currenciesUseCase: try resolver.resolveDependency(),
                exchangeRatesUseCase: try resolver.resolveDependency(),
                currencyConversionUseCase: try resolver.resolveDependency(),
                currencyPresentationMapper: try resolver.resolveDependency()
            )
            return AnyView(ExchangeCalculatorView(viewModel: viewModel))
        } catch {
            assertionFailure("ExchangePageRouter: dependency resolution failed — \(error)")
            return AnyView(EmptyView())
        }
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
