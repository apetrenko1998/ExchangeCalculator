//
//  DIContainer+Utilities.swift
//  Utilities
//
//  Created by Антон Петренко on 25/05/2026.
//

import Foundation

public extension DependencyContainer {
    public func registerUtilitiesDependencies() {
        self.register(scope: .transient) { resolver in
            let environment: EnvironmentInterface = EnvironmentConfiguration()
            return environment
        }
    }
}
