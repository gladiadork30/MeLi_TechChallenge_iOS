import SwiftUI

/// Renderiza las 4 secciones del resumen (RF-07).
struct SummarySectionView: View {
    let summary: ReviewSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sentimentSection
            tagline
            if !summary.strengths.isEmpty {
                bulletList(
                    title: String(localized: "summary.strengths_title"),
                    items: summary.strengths,
                    icon: "plus.circle.fill",
                    tint: .green
                )
            }
            if !summary.weaknesses.isEmpty {
                bulletList(
                    title: String(localized: "summary.weaknesses_title"),
                    items: summary.weaknesses,
                    icon: "minus.circle.fill",
                    tint: .red
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var sentimentSection: some View {
        Label {
            Text(sentimentTitle)
                .font(.subheadline.weight(.semibold))
        } icon: {
            Image(systemName: sentimentIcon)
                .foregroundStyle(sentimentTint)
        }
    }

    private var tagline: some View {
        Text(summary.tagline)
            .font(.body.italic())
            .foregroundStyle(.primary)
    }

    private func bulletList(title: String, items: [String], icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: icon)
                        .foregroundStyle(tint)
                        .font(.caption)
                    Text(item)
                        .font(.body)
                }
            }
        }
    }

    private var sentimentTitle: String {
        switch summary.sentiment {
        case .positive: return String(localized: "summary.sentiment_positive")
        case .neutral:  return String(localized: "summary.sentiment_neutral")
        case .negative: return String(localized: "summary.sentiment_negative")
        }
    }

    private var sentimentIcon: String {
        switch summary.sentiment {
        case .positive: return "face.smiling"
        case .neutral:  return "face.dashed"
        case .negative: return "face.smiling.inverse"
        }
    }

    private var sentimentTint: Color {
        switch summary.sentiment {
        case .positive: return .green
        case .neutral:  return .secondary
        case .negative: return .red
        }
    }
}

#Preview {
    SummarySectionView(summary: ReviewSummary(
        productId: "p",
        sentiment: .positive,
        strengths: ["Excelente sonido", "Buena duración de batería"],
        weaknesses: ["Carga lenta"],
        tagline: "Auriculares sólidos para uso diario, con batería que cumple.",
        generatedAt: .now
    ))
    .padding()
}
