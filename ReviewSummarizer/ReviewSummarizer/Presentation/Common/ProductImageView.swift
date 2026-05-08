import SwiftUI

/// Vista compartida para imágenes de productos servidas desde un repositorio
/// público externo HTTPS (Picsum, RF-17).
///
/// Usa `AsyncImage` con `AsyncImagePhase` explícito para diferenciar:
/// - `.empty`: spinner sobre placeholder mientras descarga.
/// - `.success`: imagen renderizada.
/// - `.failure`: placeholder estático (CA-RF-02 actualizado).
///
/// La caché HTTP la maneja `URLSession.shared.URLCache` (RF-17, plan §10.5).
struct ProductImageView: View {
    let url: URL?
    let cornerRadius: CGFloat

    init(url: URL?, cornerRadius: CGFloat = 8) {
        self.url = url
        self.cornerRadius = cornerRadius
    }

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
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.secondary.opacity(0.15))
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
        .padding()
}

#Preview("URL inválida → .failure → placeholder") {
    // Path inexistente bajo el dominio Picsum.
    ProductImageView(url: URL(string: "https://picsum.photos/notfound/x"))
        .frame(width: 120, height: 120)
        .padding()
}

#Preview("URL nil → .empty → placeholder") {
    ProductImageView(url: nil)
        .frame(width: 120, height: 120)
        .padding()
}
