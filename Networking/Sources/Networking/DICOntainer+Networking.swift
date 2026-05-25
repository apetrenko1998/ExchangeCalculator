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
        self.register(scope: .transient) { resolver in
            let session: SessionProvider = URLSession.shared
            return session
        }
        self.register(scope: .transient) { resolver in
            let session: NetworkClientInterface = NetworkService(session: resolver.resolveDependency())
            return session
        }
    }
}
