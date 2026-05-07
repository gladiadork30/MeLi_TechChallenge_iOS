import SwiftUI

/// Celda de una review individual (RF-04, S-15).
struct ReviewRowView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(review.author)
                    .font(.subheadline.weight(.semibold))
                Spacer(minLength: 0)
                StarRowView(rating: review.rating)
            }
            Text(review.text)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("review.a11y \(review.author) \(review.rating) \(review.text)"))
    }
}

/// Fila de N estrellas llenas (1...5).
private struct StarRowView: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    List {
        ReviewRowView(review: Review(author: "Ana", rating: 5, text: "Excelente relación calidad/precio."))
        ReviewRowView(review: Review(author: "Juan", rating: 3, text: "Cumple lo justo. La batería podría durar más."))
    }
}
