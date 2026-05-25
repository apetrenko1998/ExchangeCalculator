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
    private let logger = Logger(subsystem: "Networking", category: "NetworkService")

    public init(session: SessionProvider) {
        self.session = session
    }

    public func perform<R: NetworkRequest>(_ request: R) async throws -> R.ResponseDataType {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.create()
        } catch {
            logger.error("Failed to build URLRequest: \(error.localizedDescription)")
            throw NetworkServiceError.systemError(error)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.fetch(request: urlRequest)
        } catch let error as NetworkServiceError {
            throw error
        } catch {
            logger.error("Transport error: \(error.localizedDescription)")
            throw NetworkServiceError.systemError(error)
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
        } catch let error as NetworkServiceError {
            logResponse(urlRequest, data: data, statusCode: httpResponse.statusCode)
            throw error
        } catch {
            logResponse(urlRequest, data: data, statusCode: httpResponse.statusCode)
            throw NetworkServiceError.decodingError(error)
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
