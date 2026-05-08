import SwiftUI

/// Vista compartida para imágenes de productos servidas desde un repositorio
/// público externo HTTPS (Picsum, RF-17).
///
/// Usa `AsyncImage` con `AsyncImagePhase` explícito para diferenciar:
/// - `.empty`: spinner sobre placeholder mientras descarga.
/// - `.success`: imagen renderizada con `scaledToFill`.
/// - `.failure`: placeholder estático (CA-RF-02 actualizado).
///
/// **Importante**: el componente NO aplica `.frame(...)` ni `.clipShape(...)`.
/// El caller debe encadenar primero `.frame(...)` y luego `.clipShape(...)`
/// — en ese orden — para que `scaledToFill` quede acotado al frame y no
/// desborde el layout circundante.
///
/// La caché HTTP la maneja `URLSession.shared.URLCache` (RF-17, plan §10.5).
struct ProductImageView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty:
                placeholder.overlay(ProgressView())
            case .failure:
                placeholder
            @unknown default:
                placeholder
            }
        }
    }

    private var placeholder: some View {
        // Sin RoundedRectangle propio: el caller aplica `.clipShape` después
        // del `.frame`, y eso recorta también el placeholder.
        Color.secondary.opacity(0.15)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }
}

// MARK: - Previews (RF-17: tres estados de AsyncImagePhase)

#Preview("URL Picsum válida → .success") {
    ProductImageView(url: URL(string: "https://picsum.photos/seed/preview/200/200"))
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
}

#Preview("URL inválida → .failure → placeholder") {
    // Path inexistente bajo el dominio Picsum.
    ProductImageView(url: URL(string: "https://picsum.photos/notfound/x"))
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
}

#Preview("URL nil → .empty → placeholder") {
    ProductImageView(url: nil)
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
}
