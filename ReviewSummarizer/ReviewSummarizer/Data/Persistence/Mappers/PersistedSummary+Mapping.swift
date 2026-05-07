import Foundation
import os

extension PersistedSummary {
    /// Crea un registro persistido a partir de la entidad de dominio.
    convenience init(from summary: ReviewSummary) {
        self.init(
            productId: summary.productId,
            sentimentRaw: summary.sentiment.rawValue,
            strengths: summary.strengths,
            weaknesses: summary.weaknesses,
            tagline: summary.tagline,
            generatedAt: summary.generatedAt
        )
    }

    /// Convierte a entidad de dominio.
    ///
    /// Si `sentimentRaw` no matchea ningún caso del enum (registro corrupto
    /// o migración con valores nuevos), se loggea y se cae a `.neutral` para
    /// no perder el resumen.
    func toDomain() -> ReviewSummary {
        let sentiment = Sentiment(rawValue: sentimentRaw) ?? {
            Logger.persistence.error(
                "Sentiment desconocido en PersistedSummary(productId=\(self.productId, privacy: .public)) raw=\(self.sentimentRaw, privacy: .public). Fallback a .neutral."
            )
            return .neutral
        }()

        return ReviewSummary(
            productId: productId,
            sentiment: sentiment,
            strengths: strengths,
            weaknesses: weaknesses,
            tagline: tagline,
            generatedAt: generatedAt
        )
    }
}
