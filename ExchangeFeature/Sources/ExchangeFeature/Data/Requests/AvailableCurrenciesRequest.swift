import Foundation
import Networking
import Utilities

public struct AvailableCurrenciesRequest: NetworkRequest {
    public typealias ResponseDataType = [CurrencyResponse]

    private let environment: EnvironmentInterface
    
    public init(environment: EnvironmentInterface) {
        self.environment = environment
    }

    public func create() throws -> URLRequest {
        var components = URLComponents()
        components.host = environment.baseURL.absoluteString
        components.scheme = "https"
        components.path = "/v1/tickers-currencies"
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    public func parse(data: Data) throws -> [CurrencyResponse] {
        try JSONDecoder().decode([CurrencyResponse].self, from: data)
    }
}
