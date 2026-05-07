import Foundation
@testable import ReviewSummarizer

/// Mock de `SummarizerService` configurable.
///
/// Permite simular: success / error / cancelación / delays / disponibilidad.
actor SummarizerServiceMock: SummarizerService {
    enum Behavior {
        case success(ReviewSummary)
        case failure(SummarizerError)
        case cancellation
        case throwingError(any Error & Sendable)
    }

    var behavior: Behavior
    var availabilityValue: SummarizerAvailability
    /// Delay en nanosegundos antes de responder. Útil para probar cancelación.
    var delayNanos: UInt64 = 0
    private(set) var summarizeCallCount: Int = 0

    init(
        behavior: Behavior,
        availability: SummarizerAvailability = .available
    ) {
        self.behavior = behavior
        self.availabilityValue = availability
    }

    var availability: SummarizerAvailability {
        get async { availabilityValue }
    }

    func setBehavior(_ behavior: Behavior) { self.behavior = behavior }
    func setAvailability(_ value: SummarizerAvailability) { self.availabilityValue = value }
    func setDelay(nanos: UInt64) { self.delayNanos = nanos }

    func summarize(reviews: [Review], productId: String) async throws -> ReviewSummary {
        summarizeCallCount += 1
        if delayNanos > 0 {
            try await Task.sleep(nanoseconds: delayNanos)
        }
        try Task.checkCancellation()
        switch behavior {
        case .success(let summary):
            return summary
        case .failure(let err):
            throw err
        case .cancellation:
            throw CancellationError()
        case .throwingError(let err):
            throw err
        }
    }
}
