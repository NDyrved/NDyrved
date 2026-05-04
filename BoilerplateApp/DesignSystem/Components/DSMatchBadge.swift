import SwiftUI

/// Dark rounded badge showing an AI match percentage — e.g. "94%".
struct DSMatchBadge: View {
    let percent: Int
    var size: BadgeSize = .regular

    enum BadgeSize {
        case small, regular, large
        var font: Font {
            switch self {
            case .small:   return DSTypography.caption2
            case .regular: return DSTypography.label
            case .large:   return DSTypography.title3
            }
        }
        var padding: EdgeInsets {
            switch self {
            case .small:   return .init(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .regular: return .init(top: 6, leading: 10, bottom: 6, trailing: 10)
            case .large:   return .init(top: 10, leading: 14, bottom: 10, trailing: 14)
            }
        }
    }

    private var badgeColor: Color {
        switch percent {
        case 90...: return DSColor.accent
        case 75..:  return Color(red: 0.25, green: 0.55, blue: 0.35)
        default:    return DSColor.textSecondary
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("AI MATCH")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.white.opacity(0.75))
            Text("\(percent)%")
                .font(size == .large ? DSTypography.score : size.font.bold())
                .foregroundStyle(.white)
        }
        .padding(size.padding)
        .background(badgeColor, in: RoundedRectangle(cornerRadius: 10))
    }
}
