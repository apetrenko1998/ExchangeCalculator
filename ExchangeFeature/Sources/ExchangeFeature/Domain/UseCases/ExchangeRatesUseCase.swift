//
//  ExchangeRatesUseCase.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

public protocol ExchangeRatesUseCaseInterface: Sendable {
    func fetch(for currencies: [Currency]) async throws -> [ExchangeRate]
}

public struct ExchangeRatesUseCase: ExchangeRatesUseCaseInterface {
    
    private let repository: ExchangeRatesRepositoryInterface
    
    public init(repository: ExchangeRatesRepositoryInterface) {
        self.repository = repository
    }
    
    public func fetch(for currencies: [Currency]) async throws -> [ExchangeRate] {
        try await repository.fetchRates(for: currencies)
    }
}
