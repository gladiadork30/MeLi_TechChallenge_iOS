import Foundation

/// Helpers de URL para construir paths de forma robusta.
extension URL {
    /// Concatena un path a una URL base, normalizando slashes.
    ///
    /// Tolera combinaciones de trailing/leading slash:
    /// - `http://h/` + `/foo` → `http://h/foo`
    /// - `http://h`  + `foo`  → `http://h/foo`
    /// - `http://h/` + `foo`  → `http://h/foo`
    ///
    /// - Parameter path: path relativo a concatenar.
    /// - Returns: URL resultante.
    func appendingPathComponentSafe(_ path: String) -> URL {
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return self.appending(path: trimmed)
    }
}
