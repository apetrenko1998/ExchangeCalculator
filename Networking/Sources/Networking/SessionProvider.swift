//
//  SessionProvider.swift
//  Networking
//
//  Created by Антон Петренко on 23/05/2026.
//

import Foundation

public protocol SessionProvider: Sendable {
    func fetch(request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: SessionProvider {
    public func fetch(request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: request)
    }
}
