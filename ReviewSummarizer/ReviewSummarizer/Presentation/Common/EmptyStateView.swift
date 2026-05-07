import SwiftUI

/// Vista de estado vacío reutilizable (RF-14).
struct EmptyStateView: View {
    let title: String
    let message: String
    let action: Action?

    struct Action {
        let label: String
        let perform: () -> Void
    }

    init(title: String, message: String, action: Action? = nil) {
        self.title = title
        self.message = message
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title3.weight(.semibold))
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if let action {
                Button {
                    action.perform()
                } label: {
                    Text(action.label)
                        .frame(minWidth: 120)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Sin acción") {
    EmptyStateView(
        title: "No hay productos disponibles",
        message: "Volvé a intentarlo más tarde."
    )
}

#Preview("Con acción") {
    EmptyStateView(
        title: "No hay productos disponibles",
        message: "Volvé a intentarlo más tarde.",
        action: .init(label: "Reintentar", perform: { })
    )
}
