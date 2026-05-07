import Foundation

/// Producto del catálogo con sus reviews embebidas.
///
/// El `id` es `String` para no acoplarse al formato del backend (S-12).
/// `imageURL` es opcional: si el DTO trae un string inválido se mapea a `nil`
/// y la UI muestra placeholder (S-13).
public struct Product: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let imageURL: URL?
    public let reviews: [Review]

    public init(id: String, title: String, imageURL: URL?, reviews: [Review]) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.reviews = reviews
    }
}
