import Foundation
import FoundationModels
import os

/// Implementación de `SummarizerService` sobre Apple Foundation Models.
///
/// Cumple RNF-02 (inferencia 100% on-device): no hay llamadas de red en
/// este path. La cancelación es cooperativa (RF-15): cuando el `Task`
/// invocador se cancela, la inferencia se aborta y `summarize` lanza
/// `CancellationError` sin llegar a `repository.upsert` (CA-RF-15).
actor FoundationModelsSummarizerService: SummarizerService {
    /// Cap por review en el reintento por context overflow (§5.4 nivel 2).
    private static let truncationCap: Int = 600

    init() {}

    var availability: SummarizerAvailability {
        get async {
            switch SystemLanguageModel.default.availability {
            case .available:
                return .available
            case .unavailable(let reason):
                return .unavailable(reason: Self.map(reason))
            }
        }
    }

    func summarize(reviews: [Review], productId: String) async throws -> ReviewSummary {
        guard !reviews.isEmpty else {
            throw SummarizerError.noReviews
        }

        // Intento 1: full reviews.
        do {
            return try await runInference(reviews: reviews, productId: productId)
        } catch let error as LanguageModelSession.GenerationError where Self.isContextOverflow(error) {
            Logger.ai.info("Context overflow detectado. Reintentando con truncado a \(Self.truncationCap) chars/review.")
        } catch is CancellationError {
            throw CancellationError()
        }

        // Intento 2: reviews truncadas.
        let truncated = PromptBuilder.truncated(reviews, maxCharsPerReview: Self.truncationCap)
        do {
            return try await runInference(reviews: truncated, productId: productId)
        } catch let error as LanguageModelSession.GenerationError where Self.isContextOverflow(error) {
            // TODO(RNF-12): map-reduce. Para MVP propagamos contextOverflow.
            Logger.ai.error("Context overflow persiste tras truncado. Map-reduce no implementado en MVP.")
            throw SummarizerError.contextOverflow
        } catch is CancellationError {
            throw CancellationError()
        }
    }

    // MARK: - Private

    private func runInference(reviews: [Review], productId: String) async throws -> ReviewSummary {
        let session = LanguageModelSession(instructions: PromptBuilder.systemInstructions)
        let prompt = PromptBuilder.userPrompt(reviews: reviews)

        let response: LanguageModelSession.Response<SummaryDraft>
        do {
            response = try await session.respond(to: prompt, generating: SummaryDraft.self)
        } catch let error as CancellationError {
            throw error
        } catch let error as LanguageModelSession.GenerationError {
            // Re-lanzamos el error específico de generación para que la lógica
            // de overflow lo capture; otros casos los traducimos.
            throw error
        } catch {
            Logger.ai.error("Inference falló: \(error.localizedDescription, privacy: .public)")
            throw SummarizerError.generationFailed
        }

        try Task.checkCancellation()
        return response.content.toDomain(productId: productId)
    }

    /// Heurística para detectar overflow de contexto sin acoplar a un
    /// case específico (la API marca todos los cases como `@unknown`).
    private static func isContextOverflow(_ error: LanguageModelSession.GenerationError) -> Bool {
        let description = String(describing: error).lowercased()
        return description.contains("context") || description.contains("exceeded")
    }

    private static func map(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> UnavailabilityReason {
        switch reason {
        case .deviceNotEligible:
            return .deviceNotEligible
        case .appleIntelligenceNotEnabled:
            return .appleIntelligenceOff
        case .modelNotReady:
            return .modelNotReady
        @unknown default:
            return .unknown
        }
    }
}
