import Foundation

extension SentimentChoice {
    func toDomain() -> Sentiment {
        switch self {
        case .positive: return .positive
        case .neutral:  return .neutral
        case .negative: return .negative
        }
    }
}

extension SummaryDraft {
    /// Convierte el draft del modelo a la entidad de dominio.
    ///
    /// Aplica defensas finales (RF-07):
    /// - tagline truncado a 140 chars (por si el modelo se pasó).
    /// - strengths/weaknesses limitados a 5 ítems c/u.
    func toDomain(productId: String, generatedAt: Date = Date()) -> ReviewSummary {
        let tagline = String(tagline.prefix(140))
        return ReviewSummary(
            productId: productId,
            sentiment: sentiment.toDomain(),
            strengths: Array(strengths.prefix(5)),
            weaknesses: Array(weaknesses.prefix(5)),
            tagline: tagline,
            generatedAt: generatedAt
        )
    }
}
