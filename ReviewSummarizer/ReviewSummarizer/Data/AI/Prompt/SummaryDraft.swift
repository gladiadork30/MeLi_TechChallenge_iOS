import Foundation
import FoundationModels

/// Schema de salida estructurada para el modelo on-device (RF-07).
///
/// Foundation Models usa `@Generable` + `@Guide` para guided generation:
/// el modelo se restringe a producir un valor que respeta el shape del tipo.
/// Esto reemplaza al parsing de texto libre y elimina una clase entera de bugs.
@Generable(description: "Resumen estructurado en español de las reviews de un producto.")
struct SummaryDraft: Sendable {
    @Guide(description: "Sentimiento general agregado de las reviews.")
    let sentiment: SentimentChoice

    @Guide(description: "Aspectos positivos recurrentes mencionados por los usuarios. Frases cortas, máximo 5 ítems.", .count(0...5))
    let strengths: [String]

    @Guide(description: "Aspectos negativos recurrentes mencionados por los usuarios. Frases cortas, máximo 5 ítems.", .count(0...5))
    let weaknesses: [String]

    @Guide(description: "Frase resumen en una sola línea, máximo 140 caracteres, en español neutro, sin emojis.")
    let tagline: String
}

/// Sentimiento general agregado, restringido a 3 valores (RF-07).
@Generable
enum SentimentChoice: String, Sendable {
    case positive
    case neutral
    case negative
}
