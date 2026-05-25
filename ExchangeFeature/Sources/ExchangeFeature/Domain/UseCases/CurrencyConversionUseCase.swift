//
//  File.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 25/05/2026.
//

import Foundation

protocol CurrencyConversionUseCaseInterface {
    func calculateQuoteAmount(baseAmount: Decimal, rate: ExchangeRate) -> Decimal
    func calculateBaseAmount(quoteAmount: Decimal, rate: ExchangeRate) -> Decimal
}

struct DefaultCurrencyConversionUseCase: CurrencyConversionUseCaseInterface {

    func calculateQuoteAmount(baseAmount: Decimal, rate: ExchangeRate) -> Decimal {
        guard rate.bid != 0 else { return 0 }
        return baseAmount * rate.bid
    }

    func calculateBaseAmount(quoteAmount: Decimal, rate: ExchangeRate) -> Decimal {
        guard rate.ask != 0 else { return 0 }
        return quoteAmount / rate.ask
    }
}
