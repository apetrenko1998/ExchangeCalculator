//
//  CurrencyPairResponse.swift
//  ExchangeFeature
//
//  Created by Антон Петренко on 24/05/2026.
//


public struct CurrencyPairResponse: Decodable, Equatable, Sendable {
    let base: CurrencyResponse
    let quote: CurrencyResponse

    public init(base: CurrencyResponse, quote: CurrencyResponse) {
        self.base = base
        self.quote = quote
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawBook = try container.decode(String.self)

        let components = rawBook.split(separator: "_", omittingEmptySubsequences: false)

        guard components.count == 2 else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid currency pair format: \(rawBook). Expected BASE_QUOTE."
            )
        }

        guard let base = CurrencyResponse(rawValue: String(components[0])) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported base currency: \(components[0]) in \(rawBook)."
            )
        }

        guard let quote = CurrencyResponse(rawValue: String(components[1])) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported quote currency: \(components[1]) in \(rawBook)."
            )
        }

        self.base = base
        self.quote = quote
    }
    
    public func toDomain() -> CurrencyPair {
        CurrencyPair(
            base: base.toDomain(),
            quote: quote.toDomain()
        )
    }
}
