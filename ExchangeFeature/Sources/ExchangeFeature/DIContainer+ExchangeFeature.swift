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
                networkClient: resolver.resolveDependency(),
                environment: resolver.resolveDependency()
            )
            return dataSource
        }
        self.register(scope: .transient) { resolver in
            let dataSource: ExchangeRatesRemoteDataSourceInterface = ExchangeRatesRemoteDataSource(
                networkClient: resolver.resolveDependency(),
                environment: resolver.resolveDependency()
            )
            return dataSource
        }
        self.register(scope: .transient) { resolver in
            let repository: CurrenciesRepositoryInterface = CurrenciesRepository(
                currencyRemote: resolver.resolveDependency(),
                currencyLocal: resolver.resolveDependency()
            )
            return repository
        }
        self.register(scope: .transient) { resolver in
            let repository: ExchangeRatesRepositoryInterface = ExchangeRatesRepository(ratesRemote: resolver.resolveDependency())
            return repository
        }
        self.register(scope: .transient) { resolver in
            let useCase: AvailableCurrenciesUseCaseInterface = AvailableCurrenciesUseCase(repository: resolver.resolveDependency())
            return useCase
        }
        self.register(scope: .transient) { resolver in
            let useCase: ExchangeRatesUseCaseInterface = ExchangeRatesUseCase(repository: resolver.resolveDependency())
            return useCase
        }
        self.register(scope: .transient) { resolver in
            let useCase: CurrencyConversionUseCaseInterface = DefaultCurrencyConversionUseCase()
            return useCase
        }
    }
}
