import Foundation

/// Modelo de UI para una celda de la lista de productos (RF-02, RF-03, RF-10).
///
/// Formatea el rating una sola vez al construir el UI model para evitar
/// recálculos en re-renders.
struct ProductListItemUIModel: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let imageURL: URL?
    let reviewCount: Int
    let ratingDisplay: RatingDisplay
    let hasCachedSummary: Bool

    enum RatingDisplay: Hashable, Sendable {
        /// Producto con reviews: número formateado a 1 decimal (ej. "4.0").
        case value(String)
        /// Producto sin reviews: la celda muestra "Sin calificación".
        case unrated
    }
}
