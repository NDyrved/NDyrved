import SwiftUI

struct DSCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding()
            .background(DSColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
