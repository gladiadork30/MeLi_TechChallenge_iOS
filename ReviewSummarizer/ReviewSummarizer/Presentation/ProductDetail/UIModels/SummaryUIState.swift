import Foundation

/// Estado del bloque "Resumen AI" en la pantalla de detalle (spec §6.2).
///
/// Mapeo directo a los 7 estados definidos en la spec:
/// - `.none` → Sin resumen aún. Muestra "Generar resumen" si aplica.
/// - `.generating` → Tarea AI activa. Indicador de progreso.
/// - `.available(summary)` → Resumen visible (cache o recién generado) +
///   botón "Regenerar".
/// - `.error(_)` → Mensaje de error + botón "Reintentar". No destruye
///   resumen previo si existía.
/// - `.unsupported` → Botón deshabilitado + "AI no disponible en este dispositivo".
/// - `.disabledByThreshold(needed:)` → "Necesita más de N reviews para
///   generar un resumen".
enum SummaryUIState: Equatable {
    case none
    case generating
    case available(ReviewSummary)
    case error(SummaryUIError)
    case unsupported(reason: UnavailabilityReason)
    case disabledByThreshold(needed: Int)
}

/// Errores presentables en la UI del detalle.
enum SummaryUIError: Equatable {
    case generationFailed
    case contextOverflow
}
