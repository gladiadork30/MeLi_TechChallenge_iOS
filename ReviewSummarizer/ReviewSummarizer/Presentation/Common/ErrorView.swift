import SwiftUI

/// Vista de error reutilizable con CTA "Reintentar" (RF-13, RF-14).
struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button {
                retry()
            } label: {
                Text("common.retry")
                    .frame(minWidth: 120)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(
        message: "No se pudo conectar con el servidor mock. Verificá que Proxyman esté corriendo.",
        retry: { }
    )
}
