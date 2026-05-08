import SwiftUI

/// Celda de la lista de productos (RF-02, RF-10).
struct ProductRowView: View {
    let item: ProductListItemUIModel

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    RatingBadgeView(display: item.ratingDisplay)
                    Text("list.review_count \(item.reviewCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)

            if item.hasCachedSummary {
                Image(systemName: "sparkles")
                    .foregroundStyle(.tint)
                    .accessibilityLabel(Text("list.has_cached_summary"))
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var thumbnail: some View {
        ProductImageView(url: item.imageURL, cornerRadius: 8)
            .frame(width: 64, height: 64)
            .accessibilityHidden(true)
    }
}

// MARK: - Previews (RF-17: cubrir los 3 casos del AsyncImagePhase)

#Preview("URL Picsum válida + cached summary") {
    ProductRowView(item: .init(
        id: "p1",
        title: "Auriculares Bluetooth XS-200",
        imageURL: URL(string: "https://picsum.photos/seed/p_001/200/200"),
        reviewCount: 18,
        ratingDisplay: .value("4.3"),
        hasCachedSummary: true
    ))
    .padding()
}

#Preview("URL inválida → placeholder por .failure") {
    // Path inexistente bajo el dominio Picsum: dispara .failure tras el GET.
    ProductRowView(item: .init(
        id: "p2",
        title: "Producto con URL rota",
        imageURL: URL(string: "https://picsum.photos/notfound/no-existe"),
        reviewCount: 8,
        ratingDisplay: .value("3.5"),
        hasCachedSummary: false
    ))
    .padding()
}

#Preview("Sin URL (nil) → placeholder por .empty") {
    ProductRowView(item: .init(
        id: "p3",
        title: "Soporte ergonómico para notebook",
        imageURL: nil,
        reviewCount: 0,
        ratingDisplay: .unrated,
        hasCachedSummary: false
    ))
    .padding()
}
