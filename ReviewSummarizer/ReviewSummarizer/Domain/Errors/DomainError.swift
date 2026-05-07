import Foundation

/// Errores expresados en el lenguaje del dominio.
///
/// Las capas externas (Data) producen errores específicos y los traducen
/// a `DomainError` antes de cruzar la frontera al dominio.
public enum DomainError: Error, Sendable {
    case network(underlying: any Error & Sendable)
    case persistence(underlying: any Error & Sendable)
    case summarizer(SummarizerError)
    case notFound
}

/// Errores específicos del motor de resumen on-device.
public enum SummarizerError: Error, Sendable, Equatable {
    /// Se intentó resumir un producto sin reviews.
    case noReviews
    /// El modelo respondió pero la generación falló por un motivo no recuperable.
    case generationFailed
    /// Las reviews exceden la ventana de contexto incluso tras truncado (RNF-12).
    case contextOverflow
    /// La inferencia se canceló cooperativamente.
    case cancelled
    /// El motor AI no está disponible en este dispositivo (RF-12).
    case unavailable
}
