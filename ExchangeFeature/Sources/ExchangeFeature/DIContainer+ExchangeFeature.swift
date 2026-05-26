//
//  File.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

import Utilities

public extension DependencyContainer {
    public func registerExchangeFeatureDependencies() {
        self.register(scope: .transient) { resolver in
            let currencyPresentationMapper: CurrencyPresentationMapping = CurrencyPresentationMapper()
            return currencyPresentationMapper
        }
        self.register(scope: .transient) { resolver in
            let dataSource: CurrencyLocalDataSourceInterface = BundledCurrencyDataSource()
            return dataSource
        }
        self.register(scope: .transient) { resolver in
            let dataSource: CurrencyRemoteDataSourceInterface = CurrencyRemoteDataSource(
                networkClient: try resolver.resolveDependency(),
                environment: try resolver.resolveDependency()
            )
            return dataSource
        }
        self.register(scope: .transient) { resolver in
            let dataSource: ExchangeRatesRemoteDataSourceInterface = ExchangeRatesRemoteDataSource(
                networkClient: try resolver.resolveDependency(),
                environment: try resolver.resolveDependency()
            )
            return dataSource
        }
        self.register(scope: .transient) { resolver in
            let repository: CurrenciesRepositoryInterface = CurrenciesRepository(
                currencyRemote: try resolver.resolveDependency(),
                currencyLocal: try resolver.resolveDependency()
            )
            return repository
        }
        self.register(scope: .transient) { resolver in
            let repository: ExchangeRatesRepositoryInterface = ExchangeRatesRepository(ratesRemote: try resolver.resolveDependency())
            return repository
        }
        self.register(scope: .transient) { resolver in
            let useCase: AvailableCurrenciesUseCaseInterface = AvailableCurrenciesUseCase(repository: try resolver.resolveDependency())
            return useCase
        }
        self.register(scope: .transient) { resolver in
            let useCase: ExchangeRatesUseCaseInterface = ExchangeRatesUseCase(repository: try resolver.resolveDependency())
            return useCase
        }
        self.register(scope: .transient) { resolver in
            let useCase: CurrencyConversionUseCaseInterface = DefaultCurrencyConversionUseCase()
            return useCase
        }
    }
}
