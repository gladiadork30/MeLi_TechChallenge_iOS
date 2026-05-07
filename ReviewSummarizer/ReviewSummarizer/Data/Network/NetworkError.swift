import Foundation

/// Errores producidos por la capa de Networking.
///
/// Las capas superiores los traducen a `DomainError.network` antes de
/// cruzar al dominio.
enum NetworkError: Error, Sendable {
    /// La URLResponse no era una HTTPURLResponse.
    case invalidResponse
    /// El status code no está en `2xx`.
    case httpStatus(Int)
    /// Falla al decodificar el body.
    case decoding(any Error & Sendable)
    /// Falla de transporte (URLError, timeout, sin conexión, etc.).
    case transport(any Error & Sendable)
}

extension NetworkError: Equatable {
    /// Igualdad por caso (sin comparar errores envueltos).
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse): return true
        case let (.httpStatus(a), .httpStatus(b)): return a == b
        case (.decoding, .decoding): return true
        case (.transport, .transport): return true
        default: return false
        }
    }
}
