import Foundation
import os

/// Implementación de `HTTPClient` sobre `URLSession`.
///
/// `actor` para aislar el estado mutable (la sesión y el decoder son
/// efectivamente inmutables, pero el aislamiento facilita la composición
/// bajo strict concurrency).
actor URLSessionHTTPClient: HTTPClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func get<T: Decodable & Sendable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponentSafe(path)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            Logger.network.error("GET \(url.absoluteString) transport error: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.transport(error as any Error & Sendable)
        }

        guard let http = response as? HTTPURLResponse else {
            Logger.network.error("GET \(url.absoluteString) invalid response (no HTTPURLResponse)")
            throw NetworkError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            Logger.network.error("GET \(url.absoluteString) status=\(http.statusCode)")
            throw NetworkError.httpStatus(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger.network.error("GET \(url.absoluteString) decoding error: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.decoding(error as any Error & Sendable)
        }
    }
}
