import Foundation
import Testing
@testable import ExchangeFeature

@Suite("ExchangeRatesUseCase")
struct ExchangeRatesUseCaseTests {

    private func makeRate(bid: Decimal, ask: Decimal, base: Currency = .usdc, quote: Currency = .mxn) -> ExchangeRate {
        ExchangeRate(ask: ask, bid: bid, book: CurrencyPair(base: base, quote: quote))
    }

    @Test func fetch_returnsRatesFromRepository() async throws {
        let rate = makeRate(bid: 17.5, ask: 18.0)
        let useCase = ExchangeRatesUseCase(repository: MockExchangeRatesRepository(result: .success([rate])))

        let rates = try await useCase.fetch(for: [.usdc, .mxn])

        #expect(rates.count == 1)
        #expect(rates[0].bid == 17.5)
        #expect(rates[0].ask == 18.0)
        #expect(rates[0].book == CurrencyPair(base: .usdc, quote: .mxn))
    }

    @Test func fetch_returnsEmptyArray_whenRepositoryReturnsEmpty() async throws {
        let useCase = ExchangeRatesUseCase(repository: MockExchangeRatesRepository(result: .success([])))

        let rates = try await useCase.fetch(for: [.usdc, .mxn])

        #expect(rates.isEmpty)
    }

    @Test func fetch_propagatesRepositoryError() async {
        let useCase = ExchangeRatesUseCase(
            repository: MockExchangeRatesRepository(result: .failure(URLError(.timedOut)))
        )

        await #expect(throws: URLError.self) {
            try await useCase.fetch(for: [.usdc, .mxn])
        }
    }

    @Test func fetch_forwardsAllCurrenciesToRepository() async throws {
        let repository = MockExchangeRatesRepository(result: .success([]))
        let useCase = ExchangeRatesUseCase(repository: repository)
        let currencies: [Currency] = [.usdc, .mxn, .ars, .cop, .brl]

        _ = try await useCase.fetch(for: currencies)

        #expect(repository.capturedCurrencies == currencies)
    }
}

// MARK: - Mock

private final class MockExchangeRatesRepository: ExchangeRatesRepositoryInterface, @unchecked Sendable {
    private let result: Result<[ExchangeRate], Error>
    private(set) var capturedCurrencies: [Currency] = []

    init(result: Result<[ExchangeRate], Error>) {
        self.result = result
    }

    func fetchRates(for currencies: [Currency]) async throws -> [ExchangeRate] {
        capturedCurrencies = currencies
        return try result.get()
    }
}
