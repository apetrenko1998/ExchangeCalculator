import Foundation

public struct ExchangeRate: Sendable {
    let ask: Decimal
    let bid: Decimal
    let book: CurrencyPair
}
