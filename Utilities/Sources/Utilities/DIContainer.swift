//
//  DIContainer.swift
//  Utilities
//
//  Created by Антон Петренко on 25/05/2026.
//

import SwiftUI

public protocol Resolver {
    func resolveDependency<T>() -> T
}

public protocol DependencyRegisterer {
    func register<T>(scope: DependencyContainer.Scope, factory: @escaping (Resolver) -> T)
}

public final class DependencyContainer: Resolver, DependencyRegisterer {
    public enum Scope {
        /// Create a new instance on each call.
        case transient
        /// Create only a single instance and cache it.
        case container
    }

    public init() {}
    
    private var transientObjects: [ObjectIdentifier: (Resolver) -> Any] = [:]
    private var containerObjects: [ObjectIdentifier: Any] = [:]
    
    public func register<T>(scope: Scope, factory: @escaping (Resolver) -> T) {
        let key = key(for: T.self)
        switch scope {
        case .transient:
            transientObjects[key] = factory
        case .container:
            transientObjects[key] = { [weak self] resolver in
                if let instance = self?.containerObjects[key] {
                    return instance
                } else {
                    let instance = factory(resolver)
                    self?.containerObjects[key] = instance
                    return instance
                }
            }
        }
    }

    public func resolveDependency<T>() -> T {
        guard let transientObject = transientObjects[key(for: T.self)] else {
            fatalError("No transient object found for \(T.self)")
        }
        return transientObject(self) as! T
    }

    // MARK: Supporting methods
    
    private func key<T>(for type: T.Type) -> ObjectIdentifier {
        return ObjectIdentifier(T.self)
    }
}
