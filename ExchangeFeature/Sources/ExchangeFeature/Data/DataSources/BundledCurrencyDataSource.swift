//
//  BundledCurrencyDataSource.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

import Foundation

public protocol CurrencyLocalDataSourceInterface: Sendable {
    func getDefaultCurrencies() -> [CurrencyResponse]
}

public final class BundledCurrencyDataSource: CurrencyLocalDataSourceInterface {
    public func getDefaultCurrencies() -> [CurrencyResponse] {
        guard let url = Bundle.module.url(forResource: "default_currencies", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([CurrencyResponse].self, from: data)) ?? []
    }
}
