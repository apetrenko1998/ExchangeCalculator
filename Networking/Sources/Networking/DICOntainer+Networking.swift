//
//  File.swift
//  Networking
//
//  Created by Антон Петренко on 25/05/2026.
//

import Utilities
import Foundation

public extension DependencyContainer {
    public func registerNetworkingDependencies() {
        self.register(scope: .container) { _ in
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 15
            config.timeoutIntervalForResource = 30
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            let session: SessionProvider = URLSession(configuration: config)
            return session
        }
        self.register(scope: .transient) { resolver in
            let session: NetworkClientInterface = NetworkService(session: try resolver.resolveDependency())
            return session
        }
    }
}
