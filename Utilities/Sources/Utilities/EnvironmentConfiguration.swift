import Foundation

public enum EnvironmentError: Error {
    case missingBaseURL
}

public protocol EnvironmentInterface: Sendable {
    var baseURL: URL { get throws }
}

struct EnvironmentConfiguration: EnvironmentInterface {
    var baseURL: URL {
        get throws {
            guard
                let host = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
                let url = URL(string: "https://\(host)")
            else {
                throw EnvironmentError.missingBaseURL
            }
            return url
        }
    }
}
