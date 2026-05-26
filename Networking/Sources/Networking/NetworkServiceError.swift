//
//  NetworkServiceError.swift
//  Networking
//
//  Created by Антон Петренко on 23/05/2026.
//

import Foundation

public enum NetworkServiceError: Error, Sendable, LocalizedError {
    case invalidResponse
    case unauthorized(Data?)
    case clientError(Int, Data?)
    case serverError(Int, Data?)
    case decodingError(DecodingError)
    case systemError(URLError)

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
