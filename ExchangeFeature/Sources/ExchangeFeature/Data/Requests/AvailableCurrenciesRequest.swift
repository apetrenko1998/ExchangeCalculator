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
        let base = try environment.baseURL.appendingPathComponent("v1/tickers-currencies")
        guard let components = URLComponents(url: base, resolvingAgainstBaseURL: false),
              let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    public func parse(data: Data) throws -> [CurrencyResponse] {
        try JSONDecoder().decode([CurrencyResponse].self, from: data)
    }
}
