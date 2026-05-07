import Foundation

/// Resultado del cálculo de rating promedio (RF-03 / RN-04).
public enum AverageRating: Hashable, Sendable {
    /// Producto con reviews: media aritmética redondeada a 1 decimal.
    case value(Double)
    /// Producto sin reviews: la UI muestra "Sin calificación".
    case unrated
}

/// Calcula el rating promedio de las reviews de un producto.
///
/// Reglas:
/// - Sin reviews → `.unrated` (no `0.0`, no `NaN`).
/// - Con reviews → media aritmética redondeada a 1 decimal.
public struct ComputeAverageRatingUseCase: Sendable {
    public init() {}

    public func execute(reviews: [Review]) -> AverageRating {
        guard !reviews.isEmpty else { return .unrated }
        let total = reviews.reduce(0) { $0 + $1.rating }
        let avg = Double(total) / Double(reviews.count)
        let rounded = (avg * 10).rounded() / 10
        return .value(rounded)
    }
}
