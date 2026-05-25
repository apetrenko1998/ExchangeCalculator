//
//  CurrenciesRepository.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

public protocol CurrenciesRepositoryInterface: Sendable {
    func fetchAvailableCurrencies() async throws -> [Currency]
}

public final class CurrenciesRepository: CurrenciesRepositoryInterface {
    private let currencyRemote: CurrencyRemoteDataSourceInterface
    private let currencyLocal: CurrencyLocalDataSourceInterface

    public init(
        currencyRemote: CurrencyRemoteDataSourceInterface,
        currencyLocal: CurrencyLocalDataSourceInterface
    ) {
        self.currencyRemote = currencyRemote
        self.currencyLocal = currencyLocal
    }

    public func fetchAvailableCurrencies() async throws -> [Currency] {
        do {
            let availableCurrencies = try await currencyRemote.fetchAvailableCurrencies()
            let currencies = availableCurrencies.map { $0.toDomain() }
            return currencies
        } catch {
            let availableCurrencies = currencyLocal.getDefaultCurrencies()
            let currencies = availableCurrencies.map { $0.toDomain() }
            return currencies
        }
    }
}
