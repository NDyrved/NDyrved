import SwiftUI

struct EmptyStateView: View {
    var icon: String? = nil
    let title: String
    let message: String

    // Legacy convenience init matching old (title:subtitle:) call sites
    init(title: String, subtitle: String) {
        self.icon = nil
        self.title = title
        self.message = subtitle
    }

    init(icon: String? = nil, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(DSColor.accent.opacity(0.5))
            }
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
