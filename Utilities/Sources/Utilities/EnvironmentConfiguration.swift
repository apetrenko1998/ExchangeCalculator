import Foundation

public protocol EnvironmentInterface: Sendable {
    var baseURL: URL { get }
}

struct EnvironmentConfiguration: EnvironmentInterface {
    var baseURL: URL {
        guard
            let host = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
            let url = URL(string: "https://\(host)")
        else {
            fatalError("BASE_URL missing or malformed in Info.plist")
        }
        return url
    }
}
