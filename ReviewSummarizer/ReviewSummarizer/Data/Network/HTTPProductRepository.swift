import Foundation

/// Implementación de `ProductRepository` sobre HTTP.
///
/// Hace `GET /products`, decodifica `[ProductDTO]` y mapea a `[Product]`.
/// Traduce `NetworkError` a `DomainError.network` para que el dominio no
/// se entere de la capa de transporte (RNF-08, §3 reglas de dependencia).
actor HTTPProductRepository: ProductRepository {
    private let client: any HTTPClient
    private let path: String

    init(client: any HTTPClient, path: String = "/products") {
        self.client = client
        self.path = path
    }

    func fetchProducts() async throws -> [Product] {
        do {
            let dtos: [ProductDTO] = try await client.get(path)
            return dtos.map { $0.toDomain() }
        } catch let error as NetworkError {
            throw DomainError.network(underlying: error)
        }
    }
}
