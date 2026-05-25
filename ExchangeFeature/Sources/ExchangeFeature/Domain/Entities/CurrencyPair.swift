//
//  CurrencyPair.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 24/05/2026.
//

public struct CurrencyPair: Equatable, Sendable {
    let base: Currency
    let quote: Currency
    
    public init(base: Currency, quote: Currency) {
        self.base = base
        self.quote = quote
    }
}
