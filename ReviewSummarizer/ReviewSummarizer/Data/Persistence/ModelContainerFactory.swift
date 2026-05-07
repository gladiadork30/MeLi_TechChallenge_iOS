import Foundation
import SwiftData

/// Factory de `ModelContainer` para la app y los tests.
///
/// Centraliza el schema (hoy un único `@Model`) y permite construir
/// contenedores in-memory para tests con setup limpio por suite.
enum ModelContainerFactory {
    /// Schema completo de la app.
    static let schema = Schema([PersistedSummary.self])

    /// Contenedor persistente para producción / debug en simulador o device.
    static func makePersistent() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Contenedor in-memory para tests unitarios.
    static func makeInMemory() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
