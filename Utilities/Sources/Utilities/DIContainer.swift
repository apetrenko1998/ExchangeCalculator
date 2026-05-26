//
//  DIContainer.swift
//  Utilities
//
//  Created by Антон Петренко on 25/05/2026.
//

import Foundation

public enum DIError: Error {
    case notRegistered(String)
}

public protocol Resolver {
    func resolveDependency<T>() throws -> T
}

public protocol DependencyRegisterer {
    func register<T>(scope: DependencyContainer.Scope, factory: @escaping (Resolver) throws -> T)
}

public final class DependencyContainer: Resolver, DependencyRegisterer {
    public enum Scope {
        /// Create a new instance on each call.
        case transient
        /// Create only a single instance and cache it.
        case container
    }

    public init() {}

    private let lock = NSLock()
    private var transientFactories: [ObjectIdentifier: (Resolver) throws -> Any] = [:]
    private var containerFactories: [ObjectIdentifier: (Resolver) throws -> Any] = [:]
    private var singletons: [ObjectIdentifier: Any] = [:]

    public func register<T>(scope: Scope, factory: @escaping (Resolver) throws -> T) {
        let key = ObjectIdentifier(T.self)
        lock.lock()
        defer { lock.unlock() }
        switch scope {
        case .transient:
            transientFactories[key] = factory
            containerFactories.removeValue(forKey: key)
        case .container:
            containerFactories[key] = factory
            transientFactories.removeValue(forKey: key)
            singletons.removeValue(forKey: key)
        }
    }

    public func resolveDependency<T>() throws -> T {
        let key = ObjectIdentifier(T.self)

        lock.lock()
        let cached = singletons[key] as? T
        lock.unlock()
        if let cached { return cached }

        lock.lock()
        let containerFactory = containerFactories[key]
        let transientFactory = transientFactories[key]
        lock.unlock()

        let isContainer = containerFactory != nil
        guard let factory = containerFactory ?? transientFactory else {
            throw DIError.notRegistered(String(describing: T.self))
        }

        let instance = try factory(self)
        guard let typed = instance as? T else {
            throw DIError.notRegistered(String(describing: T.self))
        }

        if isContainer {
            lock.lock()
            if singletons[key] == nil { singletons[key] = typed }
            lock.unlock()
        }

        return typed
    }
}
