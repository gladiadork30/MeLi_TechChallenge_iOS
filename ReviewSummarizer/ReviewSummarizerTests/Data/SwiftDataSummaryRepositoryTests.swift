import Testing
import SwiftData
import Foundation
@testable import ReviewSummarizer

@Suite("SwiftDataSummaryRepository (in-memory)")
struct SwiftDataSummaryRepositoryTests {

    private func makeSUT() throws -> SwiftDataSummaryRepository {
        let container = try ModelContainerFactory.makeInMemory()
        return SwiftDataSummaryRepository(container: container)
    }

    @Test("upsert + fetch devuelve el resumen guardado (RN-02)")
    func insertAndFetch() async throws {
        let sut = try makeSUT()
        let summary = ReviewSummary.fixture(productId: "p1")

        try await sut.upsert(summary)
        let fetched = try await sut.fetch(productId: "p1")

        #expect(fetched == summary)
    }

    @Test("upsert sobre productId existente reemplaza (RN-03 / CA-RF-09)")
    func upsertReplaces() async throws {
        let sut = try makeSUT()
        let original = ReviewSummary.fixture(productId: "p1", tagline: "Original")
        let updated  = ReviewSummary.fixture(productId: "p1", tagline: "Actualizado")

        try await sut.upsert(original)
        try await sut.upsert(updated)
        let fetched = try await sut.fetch(productId: "p1")

        #expect(fetched?.tagline == "Actualizado")
    }

    @Test("fetchAllProductIds devuelve set correcto (RF-10)")
    func fetchAllIds() async throws {
        let sut = try makeSUT()
        try await sut.upsert(.fixture(productId: "p1"))
        try await sut.upsert(.fixture(productId: "p2"))

        let ids = try await sut.fetchAllProductIds()
        #expect(ids == Set(["p1", "p2"]))
    }

    @Test("delete elimina el registro")
    func deleteRecord() async throws {
        let sut = try makeSUT()
        try await sut.upsert(.fixture(productId: "p1"))
        try await sut.delete(productId: "p1")

        let fetched = try await sut.fetch(productId: "p1")
        #expect(fetched == nil)
    }

    @Test("fetch de id inexistente → nil")
    func fetchMissing() async throws {
        let sut = try makeSUT()
        let fetched = try await sut.fetch(productId: "no-existe")
        #expect(fetched == nil)
    }
}
