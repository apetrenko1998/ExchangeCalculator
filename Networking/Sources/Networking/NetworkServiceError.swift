//
//  NetworkServiceError.swift
//  Networking
//
//  Created by Антон Петренко on 23/05/2026.
//

import Foundation

// @unchecked Sendable: associated Error values are value types in practice (DecodingError, URLError),
// but the compiler cannot prove it via the existential.
public enum NetworkServiceError: Error, @unchecked Sendable, LocalizedError {
    case invalidResponse
    case unauthorized(Data?)
    case clientError(Int, Data?)
    case serverError(Int, Data?)
    case decodingError(any Error)
    case systemError(any Error)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .unauthorized:
            return "Authentication required. Please sign in again."
        case .clientError(let code, _):
            return "Request failed with client error \(code)."
        case .serverError(let code, _):
            return "Server error \(code). Please try again later."
        case .decodingError(let error):
            return "Failed to decode server response: \(error.localizedDescription)"
        case .systemError(let error):
            return error.localizedDescription
        }
    }
}
