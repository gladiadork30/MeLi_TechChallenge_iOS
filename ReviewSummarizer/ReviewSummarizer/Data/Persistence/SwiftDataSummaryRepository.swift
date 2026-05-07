import Foundation
import SwiftData
import os

/// Implementación de `SummaryRepository` sobre SwiftData.
///
/// Un `actor` que envuelve un `ModelContainer`. Cada operación abre un
/// `ModelContext` propio: SwiftData no garantiza que `ModelContext` sea
/// `Sendable`, así que se mantiene local al `Task` que ejecuta la operación.
///
/// El upsert se apoya en `@Attribute(.unique) var productId` para que la
/// regeneración (RF-09 / RN-03) reemplace en lugar de acumular.
actor SwiftDataSummaryRepository: SummaryRepository {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func fetch(productId: String) async throws -> ReviewSummary? {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<PersistedSummary>(
            predicate: #Predicate { $0.productId == productId }
        )
        do {
            return try context.fetch(descriptor).first?.toDomain()
        } catch {
            Logger.persistence.error("fetch(productId:\(productId, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
            throw DomainError.persistence(underlying: error as any Error & Sendable)
        }
    }

    func fetchAllProductIds() async throws -> Set<String> {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<PersistedSummary>()
        do {
            let all = try context.fetch(descriptor)
            return Set(all.map(\.productId))
        } catch {
            Logger.persistence.error("fetchAllProductIds failed: \(error.localizedDescription, privacy: .public)")
            throw DomainError.persistence(underlying: error as any Error & Sendable)
        }
    }

    func upsert(_ summary: ReviewSummary) async throws {
        let context = ModelContext(container)
        let pid = summary.productId
        let descriptor = FetchDescriptor<PersistedSummary>(
            predicate: #Predicate { $0.productId == pid }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.sentimentRaw = summary.sentiment.rawValue
                existing.strengths = summary.strengths
                existing.weaknesses = summary.weaknesses
                existing.tagline = summary.tagline
                existing.generatedAt = summary.generatedAt
            } else {
                context.insert(PersistedSummary(from: summary))
            }
            try context.save()
        } catch {
            Logger.persistence.error("upsert(productId:\(pid, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
            throw DomainError.persistence(underlying: error as any Error & Sendable)
        }
    }

    func delete(productId: String) async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<PersistedSummary>(
            predicate: #Predicate { $0.productId == productId }
        )
        do {
            for record in try context.fetch(descriptor) {
                context.delete(record)
            }
            try context.save()
        } catch {
            Logger.persistence.error("delete(productId:\(productId, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
            throw DomainError.persistence(underlying: error as any Error & Sendable)
        }
    }
}
