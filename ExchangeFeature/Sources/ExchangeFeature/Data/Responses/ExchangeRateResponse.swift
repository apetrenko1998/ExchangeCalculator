import Foundation

public struct ExchangeRateResponse: Decodable,Sendable {
    let ask: Decimal
    let bid: Decimal
    let book: CurrencyPairResponse

    enum CodingKeys: String, CodingKey {
        case ask, bid, book
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let askString = try container.decode(String.self, forKey: .ask)
        let bidString = try container.decode(String.self, forKey: .bid)
        guard let askDecimal = Decimal(string: askString) else {
            throw DecodingError.dataCorruptedError(forKey: .ask, in: container, debugDescription: "Cannot convert '\(askString)' to Decimal")
        }
        guard let bidDecimal = Decimal(string: bidString) else {
            throw DecodingError.dataCorruptedError(forKey: .bid, in: container, debugDescription: "Cannot convert '\(bidString)' to Decimal")
        }
        ask = askDecimal
        bid = bidDecimal
        book = try container.decode(CurrencyPairResponse.self, forKey: .book)
    }

    public func toDomain() -> ExchangeRate {
        ExchangeRate(
            ask: ask,
            bid: bid,
            book: book.toDomain()
        )
    }
}

