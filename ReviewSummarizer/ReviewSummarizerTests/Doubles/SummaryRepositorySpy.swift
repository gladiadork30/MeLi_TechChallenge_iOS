import Foundation
@testable import ReviewSummarizer

/// Spy de `SummaryRepository`: registra llamadas a upsert/delete y permite
/// inyectar respuestas para fetch.
actor SummaryRepositorySpy: SummaryRepository {
    // MARK: Inyección
    var fetchResult: ReviewSummary?
    var fetchAllIdsResult: Set<String> = []
    var fetchError: (any Error & Sendable)?
    var upsertError: (any Error & Sendable)?

    // MARK: Registros
    private(set) var upsertedSummaries: [ReviewSummary] = []
    private(set) var deletedProductIds: [String] = []

    var upsertCount: Int { upsertedSummaries.count }
    var deleteCount: Int { deletedProductIds.count }

    init(
        fetchResult: ReviewSummary? = nil,
        fetchAllIds: Set<String> = [],
        fetchError: (any Error & Sendable)? = nil,
        upsertError: (any Error & Sendable)? = nil
    ) {
        self.fetchResult = fetchResult
        self.fetchAllIdsResult = fetchAllIds
        self.fetchError = fetchError
        self.upsertError = upsertError
    }

    func setFetchResult(_ summary: ReviewSummary?) { self.fetchResult = summary }
    func setFetchAllIds(_ ids: Set<String>) { self.fetchAllIdsResult = ids }

    // MARK: SummaryRepository

    func fetch(productId: String) async throws -> ReviewSummary? {
        if let fetchError { throw fetchError }
        return fetchResult
    }

    func fetchAllProductIds() async throws -> Set<String> {
        if let fetchError { throw fetchError }
        return fetchAllIdsResult
    }

    func upsert(_ summary: ReviewSummary) async throws {
        if let upsertError { throw upsertError }
        upsertedSummaries.append(summary)
    }

    func delete(productId: String) async throws {
        deletedProductIds.append(productId)
    }
}
