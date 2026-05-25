//
//  AvailableCurrenciesUseCase.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

import Foundation

public protocol AvailableCurrenciesUseCaseInterface: Sendable {
    func fetch() async throws -> [Currency]
}

public struct AvailableCurrenciesUseCase: AvailableCurrenciesUseCaseInterface {
    
    private let repository: CurrenciesRepositoryInterface
    
    public init(repository: CurrenciesRepositoryInterface) {
        self.repository = repository
    }
    
    public func fetch() async throws -> [Currency] {
        try await repository.fetchAvailableCurrencies()
    }
}
