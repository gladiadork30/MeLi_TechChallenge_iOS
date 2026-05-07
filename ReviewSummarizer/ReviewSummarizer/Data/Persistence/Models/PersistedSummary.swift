import Foundation
import SwiftData

/// Modelo persistido de un resumen AI.
///
/// `productId` es la clave única (RN-02 / RN-03): la regeneración hace
/// upsert atómico sobre el mismo registro, no acumula versiones.
///
/// `sentimentRaw` se almacena como `String` para evitar acoplar SwiftData
/// al enum del dominio; el mapper aplica `Sentiment(rawValue:)` con fallback.
@Model
final class PersistedSummary {
    @Attribute(.unique) var productId: String
    var sentimentRaw: String
    var strengths: [String]
    var weaknesses: [String]
    var tagline: String
    var generatedAt: Date

    init(
        productId: String,
        sentimentRaw: String,
        strengths: [String],
        weaknesses: [String],
        tagline: String,
        generatedAt: Date
    ) {
        self.productId = productId
        self.sentimentRaw = sentimentRaw
        self.strengths = strengths
        self.weaknesses = weaknesses
        self.tagline = tagline
        self.generatedAt = generatedAt
    }
}
