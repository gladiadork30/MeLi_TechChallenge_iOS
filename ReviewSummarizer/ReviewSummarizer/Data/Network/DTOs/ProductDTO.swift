import Foundation

/// DTO de un producto tal como lo entrega el backend mock.
///
/// `imageUrl` y `reviews` son opcionales para tolerar respuestas incompletas
/// del mock; el mapping decide los defaults seguros.
struct ProductDTO: Decodable, Sendable {
    let id: String
    let title: String
    let imageUrl: String?
    let reviews: [ReviewDTO]?
}
