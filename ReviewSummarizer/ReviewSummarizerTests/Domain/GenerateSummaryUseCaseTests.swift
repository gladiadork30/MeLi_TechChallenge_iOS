import Testing
import Foundation
@testable import ReviewSummarizer

@Suite("GenerateSummaryUseCase (CA-RF-09, CA-RF-15)")
struct GenerateSummaryUseCaseTests {

    @Test("Éxito → upsert llamado 1 vez con el resumen correcto")
    func happyPath() async throws {
        let summary = ReviewSummary.fixture(productId: "p1")
        let summarizer = SummarizerServiceMock(behavior: .success(summary))
        let repo = SummaryRepositorySpy()
        let sut = GenerateSummaryUseCase(summarizer: summarizer, repository: repo)

        let result = try await sut.execute(productId: "p1", reviews: [.fixture()])

        #expect(result == summary)
        await #expect(repo.upsertCount == 1)
        await #expect(repo.upsertedSummaries.first == summary)
    }

    @Test("Error de summarizer → upsert NO se llama")
    func summarizerError() async {
        let summarizer = SummarizerServiceMock(behavior: .failure(.generationFailed))
        let repo = SummaryRepositorySpy()
        let sut = GenerateSummaryUseCase(summarizer: summarizer, repository: repo)

        await #expect(throws: SummarizerError.self) {
            _ = try await sut.execute(productId: "p1", reviews: [.fixture()])
        }
        await #expect(repo.upsertCount == 0)
    }

    @Test("Cancelación durante summarize → upsert NO se llama y propaga CancellationError")
    func cancellation() async {
        let summarizer = SummarizerServiceMock(behavior: .cancellation)
        let repo = SummaryRepositorySpy()
        let sut = GenerateSummaryUseCase(summarizer: summarizer, repository: repo)

        await #expect(throws: CancellationError.self) {
            _ = try await sut.execute(productId: "p1", reviews: [.fixture()])
        }
        await #expect(repo.upsertCount == 0)
    }
}
