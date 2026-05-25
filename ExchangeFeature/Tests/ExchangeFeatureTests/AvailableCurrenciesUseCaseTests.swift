import Foundation
import Testing
@testable import ExchangeFeature

@Suite("AvailableCurrenciesUseCase")
struct AvailableCurrenciesUseCaseTests {

    @Test func fetch_returnsCurrenciesFromRepository() async throws {
        let expected: [Currency] = [.usdc, .mxn, .ars]
        let useCase = AvailableCurrenciesUseCase(repository: MockCurrenciesRepository(result: .success(expected)))

        let currencies = try await useCase.fetch()

        #expect(currencies == expected)
    }

    @Test func fetch_returnsEmptyArray_whenRepositoryReturnsEmpty() async throws {
        let useCase = AvailableCurrenciesUseCase(repository: MockCurrenciesRepository(result: .success([])))

        let currencies = try await useCase.fetch()

        #expect(currencies.isEmpty)
    }

    @Test func fetch_propagatesRepositoryError() async {
        let useCase = AvailableCurrenciesUseCase(
            repository: MockCurrenciesRepository(result: .failure(URLError(.notConnectedToInternet)))
        )

        await #expect(throws: URLError.self) {
            try await useCase.fetch()
        }
    }
}

// MARK: - Mock

private final class MockCurrenciesRepository: CurrenciesRepositoryInterface {
    private let result: Result<[Currency], Error>

    init(result: Result<[Currency], Error>) {
        self.result = result
    }

    func fetchAvailableCurrencies() async throws -> [Currency] {
        try result.get()
    }
}
