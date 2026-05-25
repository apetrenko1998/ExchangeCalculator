//
//  CurrencyRemoteDataSource.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

import Networking
import Utilities

public protocol CurrencyRemoteDataSourceInterface: Sendable {
    func fetchAvailableCurrencies() async throws -> [CurrencyResponse]
}

public final class CurrencyRemoteDataSource: CurrencyRemoteDataSourceInterface {
    private let networkClient: NetworkClientInterface
    private let environment: EnvironmentInterface
    
    init(networkClient: NetworkClientInterface, environment: EnvironmentInterface) {
        self.networkClient = networkClient
        self.environment = environment
    }
    
    public func fetchAvailableCurrencies() async throws -> [CurrencyResponse] {
        let currencies = try await networkClient.perform(AvailableCurrenciesRequest(environment: environment))
        return currencies
    }
}
