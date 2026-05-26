import Foundation
import Testing
@testable import ExchangeFeature

@Suite("DefaultCurrencyConversionUseCase")
struct CurrencyConversionUseCaseTests {

    private let useCase = DefaultCurrencyConversionUseCase()

    private func makeRate(bid: Decimal, ask: Decimal) -> ExchangeRate {
        ExchangeRate(
            ask: ask,
            bid: bid,
            book: CurrencyPair(base: .usdc, quote: .mxn)
        )
    }

    // MARK: - calculateQuoteAmount

    @Test func calculateQuoteAmount_usesMidRate() {
        // mid = (17.5 + 18.5) / 2 = 18
        let result = useCase.calculateQuoteAmount(baseAmount: 100, rate: makeRate(bid: 17.5, ask: 18.5))
        #expect(result == 1800)
    }

    @Test func calculateQuoteAmount_returnsZero_whenMidIsZero() {
        let result = useCase.calculateQuoteAmount(baseAmount: 100, rate: makeRate(bid: 0, ask: 0))
        #expect(result == 0)
    }

    @Test func calculateQuoteAmount_withZeroBaseAmount() {
        let result = useCase.calculateQuoteAmount(baseAmount: 0, rate: makeRate(bid: 17.5, ask: 18.5))
        #expect(result == 0)
    }

    // MARK: - calculateBaseAmount

    @Test func calculateBaseAmount_usesMidRate() {
        // mid = (17.5 + 18.5) / 2 = 18
        let result = useCase.calculateBaseAmount(quoteAmount: 1800, rate: makeRate(bid: 17.5, ask: 18.5))
        #expect(result == 100)
    }

    @Test func calculateBaseAmount_returnsZero_whenMidIsZero() {
        let result = useCase.calculateBaseAmount(quoteAmount: 1800, rate: makeRate(bid: 0, ask: 0))
        #expect(result == 0)
    }

    @Test func calculateBaseAmount_withZeroQuoteAmount() {
        let result = useCase.calculateBaseAmount(quoteAmount: 0, rate: makeRate(bid: 17.5, ask: 18.5))
        #expect(result == 0)
    }

    // MARK: - Round-trip

    @Test func roundTrip_isSymmetric_withSpread() {
        // bid != ask — midpoint ensures no loss on round-trip
        let rate = makeRate(bid: 17.5, ask: 18.5)
        let original: Decimal = 100
        let quote = useCase.calculateQuoteAmount(baseAmount: original, rate: rate)
        let recovered = useCase.calculateBaseAmount(quoteAmount: quote, rate: rate)
        #expect(recovered == original)
    }
}
