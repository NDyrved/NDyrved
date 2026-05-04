import SwiftUI

struct DSCard<Content: View>: View {
    @ViewBuilder let content: Content
    var padding: CGFloat = 16

    var body: some View {
        content
            .padding(padding)
            .background(DSColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
    }
}
