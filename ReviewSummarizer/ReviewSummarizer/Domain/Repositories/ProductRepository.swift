import Foundation

/// Acceso a productos del catálogo.
///
/// Implementación concreta vive en `Data/Network/HTTPProductRepository`.
/// El dominio no conoce URLSession, DTOs ni decoding.
public protocol ProductRepository: Sendable {
    /// Recupera el listado completo de productos del backend mock.
    ///
    /// Sin paginación (S-06): el endpoint devuelve los 100+ productos en
    /// una sola respuesta.
    ///
    /// - Throws: `DomainError.network` ante fallas de transporte/decoding.
    func fetchProducts() async throws -> [Product]
}
