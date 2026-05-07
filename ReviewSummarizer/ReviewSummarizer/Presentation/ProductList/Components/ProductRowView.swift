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

    @ViewBuilder
    private var thumbnail: some View {
        AsyncImage(url: item.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty:
                placeholder
                    .overlay(ProgressView())
            case .failure:
                placeholder
            @unknown default:
                placeholder
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondary.opacity(0.15))
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview("Con resumen y rating") {
    ProductRowView(item: .init(
        id: "p1",
        title: "Auriculares Bluetooth XS-200",
        imageURL: nil,
        reviewCount: 18,
        ratingDisplay: .value("4.3"),
        hasCachedSummary: true
    ))
    .padding()
}

#Preview("Sin reviews") {
    ProductRowView(item: .init(
        id: "p2",
        title: "Soporte ergonómico para notebook",
        imageURL: nil,
        reviewCount: 0,
        ratingDisplay: .unrated,
        hasCachedSummary: false
    ))
    .padding()
}
