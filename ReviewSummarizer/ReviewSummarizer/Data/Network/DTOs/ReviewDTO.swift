import Foundation

/// DTO de una review tal como la entrega el backend mock.
///
/// El mapping a la entidad de dominio (`ReviewDTO+Mapping`) aplica filtrado
/// defensivo: ratings fuera de `1...5` se descartan.
struct ReviewDTO: Decodable, Sendable {
    let author: String
    let rating: Int
    let text: String
}
