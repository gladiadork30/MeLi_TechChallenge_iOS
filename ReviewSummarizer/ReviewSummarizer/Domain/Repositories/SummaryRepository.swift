import Foundation

/// Persistencia local de resúmenes generados (RF-08, RF-09, RF-10).
///
/// Los resúmenes se asocian al `productId` del producto. La implementación
/// concreta usa SwiftData con `@Attribute(.unique) var productId` para
/// garantizar upsert atómico (RN-02, RN-03).
public protocol SummaryRepository: Sendable {
    /// Devuelve el resumen persistido para un producto, o `nil` si no existe.
    func fetch(productId: String) async throws -> ReviewSummary?

    /// Devuelve el conjunto de `productId` que tienen resumen persistido.
    ///
    /// Usado por la lista para alimentar el indicador "tiene resumen" (RF-10).
    func fetchAllProductIds() async throws -> Set<String>

    /// Inserta o reemplaza el resumen para `summary.productId`.
    ///
    /// La regeneración (RF-09 / RN-03) reemplaza, no acumula.
    func upsert(_ summary: ReviewSummary) async throws

    /// Elimina el resumen asociado a `productId` si existe.
    func delete(productId: String) async throws
}
