import Foundation

/// Recupera el resumen previamente persistido para un producto (RF-08).
///
/// Wrapper delgado sobre `SummaryRepository.fetch`. Devuelve `nil` si no existe.
public struct GetCachedSummaryUseCase: Sendable {
    private let repository: any SummaryRepository

    public init(repository: any SummaryRepository) {
        self.repository = repository
    }

    public func execute(productId: String) async throws -> ReviewSummary? {
        try await repository.fetch(productId: productId)
    }
}
