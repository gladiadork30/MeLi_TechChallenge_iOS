import Foundation

/// Opinión individual sobre un producto.
///
/// El `rating` se asume en `1...5` por contrato del backend; el filtrado
/// defensivo de valores fuera de rango ocurre en el mapping de `ReviewDTO`.
public struct Review: Hashable, Sendable {
    public let author: String
    public let rating: Int
    public let text: String

    public init(author: String, rating: Int, text: String) {
        self.author = author
        self.rating = rating
        self.text = text
    }
}
