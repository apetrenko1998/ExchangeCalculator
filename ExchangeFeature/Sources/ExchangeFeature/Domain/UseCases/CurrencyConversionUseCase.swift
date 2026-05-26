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
        let mid = midRate(rate)
        guard mid != 0 else { return 0 }
        return baseAmount * mid
    }

    func calculateBaseAmount(quoteAmount: Decimal, rate: ExchangeRate) -> Decimal {
        let mid = midRate(rate)
        guard mid != 0 else { return 0 }
        return quoteAmount / mid
    }

    private func midRate(_ rate: ExchangeRate) -> Decimal {
        (rate.bid + rate.ask) / 2
    }
}
