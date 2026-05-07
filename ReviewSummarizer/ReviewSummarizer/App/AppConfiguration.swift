import Foundation

/// Configuración de runtime resuelta al iniciar la app.
///
/// La URL base del backend mock se obtiene en este orden de prioridad:
/// 1. Variable de entorno `BACKEND_BASE_URL` (override para tests / QA).
/// 2. Clave `BackendBaseURL` en `Info.plist`, alimentada desde `Config/*.xcconfig`.
///
/// Cumple RF-01 (configurable sin recompilar el binario) y RNF-07.
struct AppConfiguration: Sendable {
    let backendBaseURL: URL

    /// Carga la configuración desde el entorno y el bundle.
    ///
    /// - Returns: la configuración resuelta.
    /// - Note: si la URL base no está presente o es inválida, dispara `preconditionFailure`.
    ///   Se considera un error de empaquetado, no de runtime.
    static func load(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        bundle: Bundle = .main
    ) -> AppConfiguration {
        // 1. Override por variable de entorno (launch arguments / tests).
        if let raw = environment["BACKEND_BASE_URL"],
           let url = URL(string: raw) {
            return AppConfiguration(backendBaseURL: url)
        }

        // 2. Lectura de Info.plist (resuelto desde xcconfig en build time).
        guard
            let raw = bundle.object(forInfoDictionaryKey: "BackendBaseURL") as? String,
            !raw.isEmpty,
            let url = URL(string: raw)
        else {
            preconditionFailure(
                "BackendBaseURL no configurada. Verificar Info.plist y Config/Debug.xcconfig."
            )
        }
        return AppConfiguration(backendBaseURL: url)
    }
}
