import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var items: [ClothingItem] = []
    @State private var showTryOn = false
    @State private var tryOnItem: ClothingItem?

    var body: some View {
        Group {
            if items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "heart")
                        .font(.system(size: 52, weight: .ultraLight))
                        .foregroundStyle(DSColor.accent.opacity(0.4))
                    Text("Your wishlist is empty")
                        .font(DSTypography.bodyMedium)
                        .foregroundStyle(DSColor.textSecondary)
                    Text("Tap the heart button when searching\na product to save it here.")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(items, id: \.id) { item in
                            WishlistItemRow(item: item,
                                onRemove: {
                                    env.outfitStore.removeFromWishlist(sourceURL: item.sourceURL)
                                    loadItems()
                                },
                                onAddToWardrobe: {
                                    item.isWishlisted = false
                                    env.outfitStore.saveClothingItem(item)
                                    loadItems()
                                },
                                onTryOn: {
                                    tryOnItem = item
                                    showTryOn = true
                                },
                                onBuy: {
                                    if let url = AffiliateService.affiliateURL(for: item.sourceURL) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(DSColor.background)
        .onAppear { loadItems() }
        .sheet(isPresented: $showTryOn) {
            if let item = tryOnItem {
                TryOnView(initialItems: [item]).environmentObject(env)
            }
        }
    }

    private func loadItems() {
        items = env.outfitStore.wishlistItems()
    }
}

// MARK: - Row
private struct WishlistItemRow: View {
    let item: ClothingItem
    let onRemove: () -> Void
    let onAddToWardrobe: () -> Void
    let onTryOn: () -> Void
    let onBuy: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            Group {
                if let data = item.imageData, let img = UIImage(data: data) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else if let urlStr = item.imageURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: DSColor.surface.overlay(ProgressView())
                        }
                    }
                } else {
                    DSColor.surface
                        .overlay(Image(systemName: item.category.icon).foregroundStyle(DSColor.textTertiary))
                }
            }
            .frame(width: 72, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.brand)
                    .font(DSTypography.caption2)
                    .foregroundStyle(DSColor.textTertiary)
                Text(item.productName.isEmpty ? "Product" : item.productName)
                    .font(DSTypography.bodyMedium)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            // Actions
            VStack(spacing: 8) {
                // Buy
                Button(action: onBuy) {
                    Image(systemName: "bag")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(DSColor.accent, in: Circle())
                }
                // Remove from wishlist
                Button(action: onRemove) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 14))
                        .foregroundStyle(.pink)
                        .frame(width: 34, height: 34)
                        .background(Color.pink.opacity(0.1), in: Circle())
                }
            }
        }
        .padding(14)
        .background(DSColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            Button("Try On", systemImage: "person.fill.viewfinder", action: onTryOn)
            Button("Move to Wardrobe", systemImage: "tshirt", action: onAddToWardrobe)
            Button("Remove", systemImage: "heart.slash", role: .destructive, action: onRemove)
        }
    }
}
