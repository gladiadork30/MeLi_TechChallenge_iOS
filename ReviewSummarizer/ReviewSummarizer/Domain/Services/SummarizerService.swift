import Foundation

/// Disponibilidad del motor de AI on-device (RF-12).
public enum SummarizerAvailability: Sendable, Equatable {
    case available
    case unavailable(reason: UnavailabilityReason)
}

/// Motivo por el que el motor de AI no está disponible.
public enum UnavailabilityReason: Sendable, Equatable {
    /// Hardware o SO sin soporte para Foundation Models.
    case deviceNotEligible
    /// El modelo aún no está descargado / preparado.
    case modelNotReady
    /// El usuario tiene Apple Intelligence desactivada.
    case appleIntelligenceOff
    /// Razón no clasificada.
    case unknown
}

/// Servicio de resumen on-device basado en Apple Foundation Models (RF-06, RNF-02).
///
/// La implementación concreta vive en `Data/AI/FoundationModelsSummarizerService`.
/// El dominio no conoce `LanguageModelSession`, `@Generable`, ni el prompt.
public protocol SummarizerService: Sendable {
    /// Disponibilidad actual del motor. Consultable on-demand al entrar al detalle.
    var availability: SummarizerAvailability { get async }

    /// Genera un resumen estructurado a partir de las reviews de un producto.
    ///
    /// - Parameters:
    ///   - reviews: reviews del producto. Debe ser no vacío.
    ///   - productId: identificador del producto para asociar el resumen.
    /// - Throws:
    ///   - `SummarizerError.noReviews` si `reviews` está vacío.
    ///   - `SummarizerError.contextOverflow` si excede el contexto incluso tras truncado.
    ///   - `SummarizerError.generationFailed` ante errores no recuperables del modelo.
    ///   - `CancellationError` si el `Task` que invoca se cancela.
    func summarize(reviews: [Review], productId: String) async throws -> ReviewSummary
}
