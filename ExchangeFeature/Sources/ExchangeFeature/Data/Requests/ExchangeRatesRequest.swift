import Foundation
import Networking
import Utilities

public struct ExchangeRatesRequest: NetworkRequest {
    public typealias ResponseDataType = [ExchangeRateResponse]
    
    private let environment: EnvironmentInterface
    private let currencies: String
    
    public init(environment: EnvironmentInterface, currencies: String) {
        self.environment = environment
        self.currencies = currencies
    }

    public func create() throws -> URLRequest {
        var components = URLComponents()
        components.host = environment.baseURL.absoluteString
        components.scheme = "https"
        components.path = "/v1/tickers"
        let currenciesItem = URLQueryItem(name: "currencies", value: currencies)
        components.queryItems = [currenciesItem]
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    public func parse(data: Data) throws -> [ExchangeRateResponse] {
        try JSONDecoder().decode([ExchangeRateResponse].self, from: data)
    }
}
