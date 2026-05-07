import Foundation

/// Constructor de prompts para el motor de resumen.
///
/// `systemInstructions` es constante (no incluye datos del producto).
/// `userPrompt` se construye por request con los reviews del producto.
enum PromptBuilder {
    /// Reglas de comportamiento del modelo. Español neutro (RN-09).
    static let systemInstructions: String = """
    Sos un asistente que resume reviews de productos de un marketplace.
    Tu salida es siempre en español neutro, conciso y honesto.

    Reglas:
    - Si las reviews son contradictorias, indicá sentimiento neutral.
    - No inventes información: solo citá aspectos que aparezcan en las reviews.
    - Listás los aspectos como frases cortas, no oraciones largas.
    - Tagline: máximo 140 caracteres, una sola línea, sin emojis.
    - No saludes ni te despidas. Solo el resumen estructurado.
    """

    /// Construye el prompt de usuario a partir de las reviews del producto.
    ///
    /// Formato por línea: `[i] ⭐rating — autor: "texto"`.
    ///
    /// Nota: el título del producto no se incluye porque la signatura del
    /// `SummarizerService` solo recibe reviews + productId. El modelo
    /// resume las opiniones sin necesidad de saber qué producto son.
    static func userPrompt(reviews: [Review]) -> String {
        let lines = reviews.enumerated().map { idx, review in
            "[\(idx + 1)] ⭐\(review.rating) — \(review.author): \"\(review.text)\""
        }
        return """
        Resumí las siguientes reviews:

        \(lines.joined(separator: "\n"))
        """
    }

    /// Trunca defensivamente el texto de cada review preservando el inicio
    /// (§5.4 nivel 2). Reviews más cortas que el cap quedan intactas.
    ///
    /// - Parameters:
    ///   - reviews: lista original.
    ///   - maxCharsPerReview: cap de caracteres por `text`.
    /// - Returns: lista con `text` truncado donde corresponda.
    static func truncated(_ reviews: [Review], maxCharsPerReview: Int) -> [Review] {
        reviews.map { review in
            guard review.text.count > maxCharsPerReview else { return review }
            let truncatedText = String(review.text.prefix(maxCharsPerReview))
            return Review(author: review.author, rating: review.rating, text: truncatedText)
        }
    }
}
