import Foundation

/// Decide si el botón de generar resumen está habilitado (RF-05 / RN-01 / S-03).
///
/// Regla: `reviewCount > 5` (estrictamente mayor; mínimo 6).
public struct CanGenerateSummaryUseCase: Sendable {
    /// Umbral mínimo de reviews para habilitar la generación.
    public static let threshold: Int = 5

    public init() {}

    public func execute(reviewCount: Int) -> Bool {
        reviewCount > Self.threshold
    }
}
