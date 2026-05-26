//
//  ExchangeRatesRemoteDataSource.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

import Networking
import Utilities

public protocol ExchangeRatesRemoteDataSourceInterface: Sendable {
    func fetchRates(for currencies: [Currency]) async throws -> [ExchangeRateResponse]
}

public final class ExchangeRatesRemoteDataSource: ExchangeRatesRemoteDataSourceInterface {
    
    private let networkClient: NetworkClientInterface
    private let environment: EnvironmentInterface
    
    public init(networkClient: NetworkClientInterface, environment: EnvironmentInterface) {
        self.networkClient = networkClient
        self.environment = environment
    }
    
    public func fetchRates(for currencies: [Currency]) async throws -> [ExchangeRateResponse] {
        let codes = currencies.map { $0.rawValue.uppercased() }.joined(separator: ",")
        let exchangeRates = try await networkClient.perform(ExchangeRatesRequest(environment: environment, currencies: codes))
        return exchangeRates
    }
}
