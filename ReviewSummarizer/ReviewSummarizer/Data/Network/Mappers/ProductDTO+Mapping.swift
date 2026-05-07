import Foundation

extension ReviewDTO {
    /// Convierte a entidad de dominio aplicando filtrado defensivo.
    ///
    /// - Returns: `nil` si el `rating` está fuera de `1...5`. La revisión se descarta.
    func toDomain() -> Review? {
        guard (1...5).contains(rating) else { return nil }
        return Review(author: author, rating: rating, text: text)
    }
}

extension ProductDTO {
    /// Convierte a entidad de dominio.
    ///
    /// - `imageUrl` inválida o vacía → `imageURL = nil` (S-13).
    /// - `reviews = nil` → `[]`.
    /// - Reviews con rating fuera de rango se descartan en cascada.
    func toDomain() -> Product {
        Product(
            id: id,
            title: title,
            imageURL: imageUrl.flatMap(URL.init(string:)),
            reviews: (reviews ?? []).compactMap { $0.toDomain() }
        )
    }
}
