import Foundation

/// Cliente HTTP genérico para GET de recursos `Decodable`.
///
/// Pensado para el alcance del MVP (un solo verb, un solo path). Si se
/// expande, se agregan métodos por demanda — no se generaliza prematuramente.
protocol HTTPClient: Sendable {
    /// Realiza un `GET` al `path` relativo a la `baseURL` y decodifica `T`.
    ///
    /// - Throws: `NetworkError.invalidResponse` / `.httpStatus(_)` /
    ///   `.decoding(_)` / `.transport(_)`.
    func get<T: Decodable & Sendable>(_ path: String) async throws -> T
}
