

public protocol ExchangeRatesRepositoryInterface: Sendable {
    func fetchRates(for currencies: [Currency]) async throws -> [ExchangeRate]
}

public final class ExchangeRatesRepository: ExchangeRatesRepositoryInterface {
    private let ratesRemote: ExchangeRatesRemoteDataSourceInterface

    public init(ratesRemote: ExchangeRatesRemoteDataSourceInterface) {
        self.ratesRemote = ratesRemote
    }

    public func fetchRates(for currencies: [Currency]) async throws -> [ExchangeRate] {
        let exchangeRates = try await ratesRemote.fetchRates(for: currencies)
        return exchangeRates.map { $0.toDomain() }
    }
}

