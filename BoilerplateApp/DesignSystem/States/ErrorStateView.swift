import SwiftUI

struct ErrorStateView: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundStyle(.red)
            .padding(.vertical, 4)
    }
}
