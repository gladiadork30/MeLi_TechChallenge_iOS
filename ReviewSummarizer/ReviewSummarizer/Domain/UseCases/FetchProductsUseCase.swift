import Foundation

/// Recupera el listado de productos (RF-02).
///
/// Wrapper delgado sobre `ProductRepository`. Se mantiene como use case por
/// consistencia de capa y para enriquecer en el futuro (ej. mezclar productos
/// con flag `hasCachedSummary`). Hoy solo delega.
public struct FetchProductsUseCase: Sendable {
    private let repository: any ProductRepository

    public init(repository: any ProductRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Product] {
        try await repository.fetchProducts()
    }
}
