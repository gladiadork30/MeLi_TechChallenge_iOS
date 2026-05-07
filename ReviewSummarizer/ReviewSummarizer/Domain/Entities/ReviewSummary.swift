import Foundation

/// Sentimiento general agregado de un conjunto de reviews.
public enum Sentiment: String, Sendable, CaseIterable, Hashable {
    case positive
    case neutral
    case negative
}

/// Resumen estructurado de las reviews de un producto, generado on-device.
///
/// Estructura definida por RF-07:
/// - sentimiento general (positive/neutral/negative)
/// - puntos fuertes (≤ 5 ítems)
/// - puntos débiles (≤ 5 ítems)
/// - tagline (≤ 140 caracteres, una línea)
public struct ReviewSummary: Hashable, Sendable {
    public let productId: String
    public let sentiment: Sentiment
    public let strengths: [String]
    public let weaknesses: [String]
    public let tagline: String
    public let generatedAt: Date

    public init(
        productId: String,
        sentiment: Sentiment,
        strengths: [String],
        weaknesses: [String],
        tagline: String,
        generatedAt: Date
    ) {
        self.productId = productId
        self.sentiment = sentiment
        self.strengths = strengths
        self.weaknesses = weaknesses
        self.tagline = tagline
        self.generatedAt = generatedAt
    }
}
