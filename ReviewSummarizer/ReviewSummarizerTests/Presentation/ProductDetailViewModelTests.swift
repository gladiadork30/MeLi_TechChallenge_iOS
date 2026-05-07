import Testing
import Foundation
@testable import ReviewSummarizer

@Suite("ProductDetailViewModel")
@MainActor
struct ProductDetailViewModelTests {
    private struct AnyError: Error & Sendable {}

    /// Construye un VM con dependencias inyectables. El mockSummarizer puede
    /// configurarse antes de pasarlo (delays, behavior, availability).
    private func makeSUT(
        product: Product = .fixture(reviewCount: 6),
        summarizer: SummarizerServiceMock,
        repo: SummaryRepositorySpy = SummaryRepositorySpy(),
        initialSummary: ReviewSummary? = nil
    ) -> ProductDetailViewModel {
        ProductDetailViewModel(
            product: product,
            summarizer: summarizer,
            getCachedSummary: GetCachedSummaryUseCase(repository: repo),
            generateSummaryUseCase: GenerateSummaryUseCase(summarizer: summarizer, repository: repo),
            canGenerateSummary: CanGenerateSummaryUseCase(),
            initialSummary: initialSummary
        )
    }

    /// Espera hasta que el estado del resumen sea terminal (.available o .error).
    /// Evita la race condition de chequear .generating antes de que el Task setee
    /// el estado.
    private func waitForGenerationFinish(
        _ vm: ProductDetailViewModel,
        timeoutMs: Int = 2000
    ) async {
        let stepNs: UInt64 = 10_000_000
        var elapsedMs = 0
        while !isTerminal(vm.summaryState) {
            try? await Task.sleep(nanoseconds: stepNs)
            elapsedMs += 10
            if elapsedMs >= timeoutMs { break }
        }
    }

    private func isTerminal(_ state: SummaryUIState) -> Bool {
        switch state {
        case .available, .error: return true
        default: return false
        }
    }

    // MARK: - T-132: estado inicial

    @Test("AI no disponible → estado .unsupported (RF-12)")
    func unavailableInitial() async {
        let summarizer = SummarizerServiceMock(
            behavior: .success(.fixture()),
            availability: .unavailable(reason: .deviceNotEligible)
        )
        let vm = makeSUT(summarizer: summarizer)
        await vm.onAppear()
        if case .unsupported(let reason) = vm.summaryState {
            #expect(reason == .deviceNotEligible)
        } else {
            Issue.record("Esperaba .unsupported, obtuvo \(vm.summaryState)")
        }
    }

    @Test("Producto con 5 reviews → estado .disabledByThreshold (RF-05)")
    func thresholdInitial() async {
        let product = Product.fixture(reviewCount: 5)
        let summarizer = SummarizerServiceMock(behavior: .success(.fixture()))
        let vm = makeSUT(product: product, summarizer: summarizer)
        await vm.onAppear()
        #expect(vm.summaryState == .disabledByThreshold(needed: 6))
    }

    @Test("Producto con resumen cacheado → estado .available (RF-08)")
    func cachedInitial() async {
        let cached = ReviewSummary.fixture(productId: "p1")
        let repo = SummaryRepositorySpy(fetchResult: cached)
        let summarizer = SummarizerServiceMock(behavior: .success(.fixture()))
        let vm = makeSUT(
            product: .fixture(id: "p1"),
            summarizer: summarizer,
            repo: repo
        )
        await vm.onAppear()
        #expect(vm.summaryState == .available(cached))
        #expect(vm.lastKnownSummary == cached)
    }

    // MARK: - T-133: generateSummary

    @Test("generateSummary éxito → .available y upsert llamado (CA-RF-09)")
    func generateSuccess() async {
        let summary = ReviewSummary.fixture(productId: "p1")
        let summarizer = SummarizerServiceMock(behavior: .success(summary))
        let repo = SummaryRepositorySpy()
        let vm = makeSUT(product: .fixture(id: "p1"), summarizer: summarizer, repo: repo)

        vm.generateSummary()
        await waitForGenerationFinish(vm)

        #expect(vm.summaryState == .available(summary))
        await #expect(repo.upsertCount == 1)
    }

    @Test("generateSummary error → .error y upsert NO llamado (CA-RF-09)")
    func generateError() async {
        let summarizer = SummarizerServiceMock(behavior: .failure(.generationFailed))
        let repo = SummaryRepositorySpy()
        let vm = makeSUT(summarizer: summarizer, repo: repo)

        vm.generateSummary()
        await waitForGenerationFinish(vm)

        if case .error = vm.summaryState { } else {
            Issue.record("Esperaba .error, obtuvo \(vm.summaryState)")
        }
        await #expect(repo.upsertCount == 0)
    }

    // MARK: - T-134: regenerateSummary preserva resumen previo en error

    @Test("Regeneración fallida → estado .error pero lastKnownSummary intacto (CA-RF-09)")
    func regenerateErrorKeepsPrevious() async {
        let previous = ReviewSummary.fixture(productId: "p1", tagline: "Original")
        let summarizer = SummarizerServiceMock(behavior: .failure(.generationFailed))
        let repo = SummaryRepositorySpy()
        let vm = makeSUT(
            product: .fixture(id: "p1"),
            summarizer: summarizer,
            repo: repo,
            initialSummary: previous
        )

        vm.regenerateSummary()
        // El estado inicial es .available(previous) (terminal), así que esperamos
        // a que pase a .error específicamente.
        await waitForErrorState(vm)

        if case .error = vm.summaryState { } else {
            Issue.record("Esperaba .error, obtuvo \(vm.summaryState)")
        }
        #expect(vm.lastKnownSummary == previous)
        await #expect(repo.upsertCount == 0)
    }

    private func waitForErrorState(_ vm: ProductDetailViewModel, timeoutMs: Int = 2000) async {
        let stepNs: UInt64 = 10_000_000
        var elapsedMs = 0
        while true {
            if case .error = vm.summaryState { return }
            try? await Task.sleep(nanoseconds: stepNs)
            elapsedMs += 10
            if elapsedMs >= timeoutMs { return }
        }
    }
}
