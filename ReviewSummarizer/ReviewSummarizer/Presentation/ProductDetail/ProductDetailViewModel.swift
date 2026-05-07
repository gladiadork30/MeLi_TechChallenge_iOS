import Foundation
import Observation
import os

/// ViewModel de la pantalla de detalle de producto.
///
/// Responsable de la matriz de estado del resumen (spec §6.2):
/// `.none / .generating / .available / .error / .unsupported / .disabledByThreshold`.
@MainActor
@Observable
final class ProductDetailViewModel {
    // MARK: - State observable
    let product: Product
    private(set) var summaryState: SummaryUIState = .none
    /// Conserva el último resumen visible para no perderlo en error de regeneración (CA-RF-09).
    private(set) var lastKnownSummary: ReviewSummary?

    // MARK: - Dependencias
    private let summarizer: any SummarizerService
    private let getCachedSummary: GetCachedSummaryUseCase
    private let generateSummaryUseCase: GenerateSummaryUseCase
    private let canGenerateSummary: CanGenerateSummaryUseCase

    // MARK: - Tasks
    private var generationTask: Task<Void, Never>?

    init(
        product: Product,
        summarizer: any SummarizerService,
        getCachedSummary: GetCachedSummaryUseCase,
        generateSummaryUseCase: GenerateSummaryUseCase,
        canGenerateSummary: CanGenerateSummaryUseCase,
        initialSummary: ReviewSummary? = nil
    ) {
        self.product = product
        self.summarizer = summarizer
        self.getCachedSummary = getCachedSummary
        self.generateSummaryUseCase = generateSummaryUseCase
        self.canGenerateSummary = canGenerateSummary
        if let initialSummary {
            self.lastKnownSummary = initialSummary
            self.summaryState = .available(initialSummary)
        }
    }

    // MARK: - Lifecycle

    /// Carga inicial: consulta cache + disponibilidad para decidir el estado
    /// inicial del resumen (RF-05, RF-08, RF-12).
    func onAppear() async {
        // 1. Cache hit → mostrar resumen aunque AI no esté disponible.
        if let cached = try? await getCachedSummary.execute(productId: product.id) {
            self.lastKnownSummary = cached
            self.summaryState = .available(cached)
            return
        }

        // 2. Sin cache: chequear umbral (RF-05).
        guard canGenerateSummary.execute(reviewCount: product.reviews.count) else {
            self.summaryState = .disabledByThreshold(needed: CanGenerateSummaryUseCase.threshold + 1)
            return
        }

        // 3. Chequear disponibilidad de AI (RF-12).
        switch await summarizer.availability {
        case .available:
            self.summaryState = .none
        case .unavailable(let reason):
            self.summaryState = .unsupported(reason: reason)
        }
    }

    /// Cancela tareas pendientes al salir del detalle (RF-11, RF-15).
    func onDisappear() {
        generationTask?.cancel()
        generationTask = nil
    }

    // MARK: - Acciones de generación

    /// Primera generación. El use case persiste solo si la inferencia
    /// devolvió un resumen válido (CA-RF-09).
    func generateSummary() {
        runGeneration(preservingPrevious: false)
    }

    /// Regeneración: idéntica a `generateSummary()` pero conserva el
    /// `lastKnownSummary` si la nueva inferencia falla (CA-RF-09).
    func regenerateSummary() {
        runGeneration(preservingPrevious: true)
    }

    // MARK: - Private

    private func runGeneration(preservingPrevious: Bool) {
        generationTask?.cancel()
        generationTask = Task { [weak self] in
            guard let self else { return }
            self.summaryState = .generating
            do {
                let summary = try await self.generateSummaryUseCase.execute(
                    productId: self.product.id,
                    reviews: self.product.reviews
                )
                if Task.isCancelled { return }
                self.lastKnownSummary = summary
                self.summaryState = .available(summary)
            } catch is CancellationError {
                // Silencio total: el usuario abandonó / canceló (CA-RF-15).
            } catch let error as SummarizerError {
                Logger.ai.error("Summarize falló: \(String(describing: error), privacy: .public)")
                let uiError: SummaryUIError = (error == .contextOverflow)
                    ? .contextOverflow
                    : .generationFailed
                if preservingPrevious, let _ = self.lastKnownSummary {
                    // CA-RF-09: regeneración fallida no destruye el resumen previo.
                    self.summaryState = .error(uiError)
                } else {
                    self.summaryState = .error(uiError)
                }
            } catch {
                Logger.ai.error("Summarize falló (dominio): \(error.localizedDescription, privacy: .public)")
                self.summaryState = .error(.generationFailed)
            }
        }
    }
}
