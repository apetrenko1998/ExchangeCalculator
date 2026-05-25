//
//  CurrencyPresentationMapper.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 24/05/2026.
//

protocol CurrencyPresentationMapping {
    func presentation(for currency: Currency) -> CurrencyPresentation
}

struct CurrencyPresentationMapper: CurrencyPresentationMapping {
    func presentation(for currency: Currency) -> CurrencyPresentation {
        switch currency {
        case .usdc:
            return CurrencyPresentation(title: "USDc", imageName: "USD")
        case .mxn:
            return CurrencyPresentation(title: "MXN", imageName: "MXN")
        case .ars:
            return CurrencyPresentation(title: "ARS", imageName: "ARS")
        case .cop:
            return CurrencyPresentation(title: "COP", imageName: "COP")
        case .brl:
            return CurrencyPresentation(title: "BRL", imageName: "BRL")
        }
    }
}
