import Foundation

/// Genera un resumen AI on-device y lo persiste (RF-06, RF-08, RF-09).
///
/// Política clave (CA-RF-09): el `upsert` **solo** ocurre tras éxito de
/// `summarize`. Si la inferencia falla o se cancela, el resumen previo
/// (si existía) queda intacto.
public struct GenerateSummaryUseCase: Sendable {
    private let summarizer: any SummarizerService
    private let repository: any SummaryRepository

    public init(
        summarizer: any SummarizerService,
        repository: any SummaryRepository
    ) {
        self.summarizer = summarizer
        self.repository = repository
    }

    /// Ejecuta la generación + persistencia.
    ///
    /// - Throws: re-propaga errores de `summarize` sin envolverlos. Si llega aquí
    ///   un `CancellationError`, no se llama a `upsert`.
    public func execute(productId: String, reviews: [Review]) async throws -> ReviewSummary {
        let summary = try await summarizer.summarize(reviews: reviews, productId: productId)
        try Task.checkCancellation()
        try await repository.upsert(summary)
        return summary
    }
}
