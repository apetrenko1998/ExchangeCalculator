//
//  NetworkService.swift
//  Networking
//
//  Created by Антон Петренко on 23/05/2026.
//

import Foundation
import OSLog

public protocol NetworkClientInterface: Sendable {
    func perform<R: NetworkRequest>(_ request: R) async throws -> R.ResponseDataType
}

public struct NetworkService: NetworkClientInterface {

    private let session: SessionProvider
    private let maxAttempts: Int
    private let retryBaseDelay: UInt64
    private let logger = Logger(subsystem: "Networking", category: "NetworkService")

    public init(session: SessionProvider, maxAttempts: Int = 3, retryBaseDelay: UInt64 = 1_000_000_000) {
        self.session = session
        self.maxAttempts = maxAttempts
        self.retryBaseDelay = retryBaseDelay
    }

    public func perform<R: NetworkRequest>(_ request: R) async throws -> R.ResponseDataType {
        var lastError: NetworkServiceError = .invalidResponse
        for attempt in 0..<maxAttempts {
            if attempt > 0 {
                let delay = retryBaseDelay * UInt64(1 << (attempt - 1))
                try await Task.sleep(nanoseconds: delay)
            }
            do {
                return try await attemptRequest(request)
            } catch let error as NetworkServiceError {
                lastError = error
                guard case .serverError(let code, _) = error, (500..<600).contains(code) else {
                    throw error
                }
                logger.warning("Server error \(code), retrying (attempt \(attempt + 1)/\(self.maxAttempts))")
            }
        }
        throw lastError
    }

    private func attemptRequest<R: NetworkRequest>(_ request: R) async throws -> R.ResponseDataType {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.create()
        } catch {
            logger.error("Failed to build URLRequest: \(error.localizedDescription)")
            throw NetworkServiceError.systemError(URLError(.badURL))
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.fetch(request: urlRequest)
        } catch let urlError as URLError {
            logger.error("Transport error: \(urlError.localizedDescription)")
            throw NetworkServiceError.systemError(urlError)
        } catch let error as NetworkServiceError {
            throw error
        } catch {
            logger.error("Transport error: \(error.localizedDescription)")
            throw NetworkServiceError.systemError(URLError(.unknown))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            logResponse(urlRequest, data: data, statusCode: httpResponse.statusCode)
            throw statusCodeError(for: httpResponse.statusCode, data: data)
        }

        do {
            return try request.parse(data: data)
        } catch let decodingError as DecodingError {
            logResponse(urlRequest, data: data, statusCode: httpResponse.statusCode)
            throw NetworkServiceError.decodingError(decodingError)
        } catch let error as NetworkServiceError {
            logResponse(urlRequest, data: data, statusCode: httpResponse.statusCode)
            throw error
        } catch {
            logResponse(urlRequest, data: data, statusCode: httpResponse.statusCode)
            throw NetworkServiceError.decodingError(
                DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: error.localizedDescription))
            )
        }
    }

    private func statusCodeError(for statusCode: Int, data: Data) -> NetworkServiceError {
        switch statusCode {
        case 401:       return .unauthorized(data)
        case 400..<500: return .clientError(statusCode, data)
        default:        return .serverError(statusCode, data)
        }
    }

    private func logResponse(_ request: URLRequest, data: Data, statusCode: Int) {
        logger.debug("""
            [\(statusCode)] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")
            Body: \(prettyJSON(request.httpBody))
            Response: \(prettyJSON(data))
            """)
    }

    private func prettyJSON(_ data: Data?) -> String {
        guard let data else { return "empty" }
        guard
            let json = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        else {
            return "malformed JSON"
        }
        return String(decoding: pretty, as: UTF8.self)
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}
