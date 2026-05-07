import Foundation
import os

/// Categorías de logging por capa de la app.
///
/// Cumple RNF-11 (logs locales, no remotos) usando Unified Logging (`os.Logger`).
/// Subsystem único basado en bundle id; categorías por capa para filtrado en Console.app.
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.reviewsummarizer.app"

    /// Capa Data — Networking (URLSession, decoding, errores HTTP).
    static let network = Logger(subsystem: subsystem, category: "network")

    /// Capa Data — Persistencia (SwiftData).
    static let persistence = Logger(subsystem: subsystem, category: "persistence")

    /// Capa Data — AI on-device (Foundation Models).
    static let ai = Logger(subsystem: subsystem, category: "ai")

    /// Capa Presentation — ViewModels y Views.
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
