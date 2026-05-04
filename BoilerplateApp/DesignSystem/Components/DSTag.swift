import SwiftUI

/// Pill-shaped occasion / category tag used across Wardrobe and Discovery screens.
struct DSTag: View {
    let label: String
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) { pill }
                    .buttonStyle(.plain)
            } else {
                pill
            }
        }
    }

    private var pill: some View {
        Text(label)
            .font(DSTypography.caption2)
            .foregroundStyle(isSelected ? .white : DSColor.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? DSColor.accent : DSColor.surface)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? DSColor.accent : DSColor.border, lineWidth: 1)
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

/// Horizontal scrollable row of selectable tags.
struct DSTagRow: View {
    let tags: [String]
    @Binding var selected: Set<String>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    DSTag(label: tag, isSelected: selected.contains(tag)) {
                        if selected.contains(tag) {
                            selected.remove(tag)
                        } else {
                            selected.insert(tag)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}
