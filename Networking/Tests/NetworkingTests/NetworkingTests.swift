import Foundation
import Testing
@testable import Networking

// MARK: - Helpers

private struct MockRequest: NetworkRequest {
    typealias ResponseDataType = String

    let url: URL = URL(string: "https://example.com/test")!

    func create() throws -> URLRequest { URLRequest(url: url) }
    func parse(data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Not UTF-8"))
        }
        return string
    }
}

private final class MockSession: SessionProvider, @unchecked Sendable {
    private var queue: [(Data, HTTPURLResponse)]
    private var index = 0

    init(_ responses: (Data, HTTPURLResponse)...) {
        self.queue = responses
    }

    func fetch(request: URLRequest) async throws -> (Data, URLResponse) {
        guard index < queue.count else { throw URLError(.badServerResponse) }
        defer { index += 1 }
        return queue[index]
    }
}

private func httpResponse(status: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: status, httpVersion: nil, headerFields: nil)!
}

private func makeService(session: MockSession, maxAttempts: Int = 1) -> NetworkService {
    NetworkService(session: session, maxAttempts: maxAttempts, retryBaseDelay: 0)
}

// MARK: - Tests

@Suite("NetworkService")
struct NetworkingTests {

    @Test func perform_returnsDecodedResponse_onSuccess() async throws {
        let body = "hello".data(using: .utf8)!
        let service = makeService(session: MockSession((body, httpResponse(status: 200))))
        let result = try await service.perform(MockRequest())
        #expect(result == "hello")
    }

    @Test func perform_throwsUnauthorized_on401() async {
        let service = makeService(session: MockSession((Data(), httpResponse(status: 401))))
        await #expect(throws: NetworkServiceError.self) {
            try await service.perform(MockRequest())
        }
    }

    @Test func perform_throwsClientError_on400() async throws {
        let service = makeService(session: MockSession((Data(), httpResponse(status: 400))))
        do {
            _ = try await service.perform(MockRequest())
            Issue.record("Expected clientError")
        } catch NetworkServiceError.clientError(let code, _) {
            #expect(code == 400)
        }
    }

    @Test func perform_throwsServerError_on500_withNoRetry() async throws {
        let service = makeService(session: MockSession((Data(), httpResponse(status: 500))), maxAttempts: 1)
        do {
            _ = try await service.perform(MockRequest())
            Issue.record("Expected serverError")
        } catch NetworkServiceError.serverError(let code, _) {
            #expect(code == 500)
        }
    }

    @Test func perform_retriesOn5xx_andSucceedsOnSecondAttempt() async throws {
        let body = "ok".data(using: .utf8)!
        let session = MockSession(
            (Data(), httpResponse(status: 503)),
            (body, httpResponse(status: 200))
        )
        let service = makeService(session: session, maxAttempts: 3)
        let result = try await service.perform(MockRequest())
        #expect(result == "ok")
    }

    @Test func perform_exhaustsRetries_andThrowsLastServerError() async throws {
        let session = MockSession(
            (Data(), httpResponse(status: 500)),
            (Data(), httpResponse(status: 502)),
            (Data(), httpResponse(status: 503))
        )
        let service = makeService(session: session, maxAttempts: 3)
        do {
            _ = try await service.perform(MockRequest())
            Issue.record("Expected serverError")
        } catch NetworkServiceError.serverError(let code, _) {
            #expect((500..<600).contains(code))
        }
    }

    @Test func perform_throwsSystemError_onURLError() async {
        final class FailingSession: SessionProvider, @unchecked Sendable {
            func fetch(request: URLRequest) async throws -> (Data, URLResponse) {
                throw URLError(.notConnectedToInternet)
            }
        }
        let service = NetworkService(session: FailingSession(), maxAttempts: 1)
        do {
            _ = try await service.perform(MockRequest())
            Issue.record("Expected systemError")
        } catch NetworkServiceError.systemError(let urlError) {
            #expect(urlError.code == .notConnectedToInternet)
        }
    }

    @Test func perform_throwsDecodingError_onBadResponse() async {
        let garbage = Data([0xFF, 0xFE])
        let service = makeService(session: MockSession((garbage, httpResponse(status: 200))))
        await #expect(throws: NetworkServiceError.self) {
            try await service.perform(MockRequest())
        }
    }
}
