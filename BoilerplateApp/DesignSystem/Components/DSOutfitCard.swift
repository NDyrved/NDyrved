import SwiftUI

/// Reusable outfit card shell used in Wardrobe and Discovery.
struct DSOutfitCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(DSColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

/// A horizontal strip of up to 4 clothing item thumbnails used inside outfit cards.
struct DSItemThumbnailStrip: View {
    let imageDataList: [Data?]
    let icons: [String]
    var height: CGFloat = 80

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(zip(imageDataList.indices, imageDataList)), id: \.0) { index, data in
                Group {
                    if let data, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                    } else {
                        DSColor.surface
                            .overlay(
                                Image(systemName: index < icons.count ? icons[index] : "hanger")
                                    .foregroundStyle(DSColor.textTertiary)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

/// Colour palette swatch strip shown at the bottom of AI suggestion cards.
struct DSColorPaletteStrip: View {
    let hexColors: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(hexColors, id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex) ?? DSColor.surface)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(DSColor.border, lineWidth: 1))
            }
        }
    }
}

// MARK: - Hex colour helper
extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        let r = Double((val >> 16) & 0xFF) / 255
        let g = Double((val >> 8)  & 0xFF) / 255
        let b = Double(val         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
