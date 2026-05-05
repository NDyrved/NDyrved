import SwiftUI

struct OutfitDetailView: View {
    @EnvironmentObject private var env: AppEnvironment
    let outfit: DiscoveryOutfit
    @Environment(\.dismiss) private var dismiss
    @State private var addedIDs = Set<UUID>()
    @State private var showTryOn = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(outfit.name)
                                    .font(DSTypography.title)
                                    .foregroundStyle(DSColor.textPrimary)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(outfit.occasionTags) { tag in DSTag(label: tag.rawValue) }
                                    }
                                }
                            }
                            Spacer()
                            DSMatchBadge(percent: outfit.aiMatchPercent, size: .large)
                        }

                        Text("LOOK ITEMS: \(outfit.items.count)")
                            .font(DSTypography.caption2)
                            .foregroundStyle(DSColor.textTertiary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)

                    // Items list
                    VStack(spacing: 12) {
                        ForEach(outfit.items) { item in
                            DiscoveryItemRow(item: item, isAdded: addedIDs.contains(item.id)) {
                                addToWardrobe(item)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // Total + action buttons
                    VStack(spacing: 12) {
                        HStack {
                            Text("Total").font(DSTypography.bodyMedium).foregroundStyle(DSColor.textSecondary)
                            Spacer()
                            Text(outfit.formattedTotal).font(DSTypography.title2).foregroundStyle(DSColor.textPrimary)
                        }

                        // Try On button
                        Button {
                            showTryOn = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill.viewfinder")
                                Text("Try On This Look")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        // Buy All button
                        Button {
                            if let url = URL(string: outfit.items.first?.productURL ?? "") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Buy Complete Look →")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Colour palette
                    if !outfit.colorPalette.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colour Palette")
                                .font(DSTypography.caption2)
                                .foregroundStyle(DSColor.textTertiary)
                            DSColorPaletteStrip(hexColors: outfit.colorPalette)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 40)
                .padding(.top, 16)
            }
            .background(DSColor.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .sheet(isPresented: $showTryOn) {
                TryOnView(initialItems: tryOnItems)
                    .environmentObject(env)
            }
        }
    }

    // Convert DiscoveryItems → ClothingItems for the try-on canvas
    private var tryOnItems: [ClothingItem] {
        outfit.items.map { item in
            ClothingItem(
                sourceURL: item.productURL,
                productName: item.name,
                brand: item.brand,
                category: item.category
            )
        }
    }

    private func addToWardrobe(_ item: DiscoveryItem) {
        let clothing = ClothingItem(
            sourceURL: item.productURL,
            productName: item.name,
            brand: item.brand,
            category: item.category
        )
        env.outfitStore.saveClothingItem(clothing)
        addedIDs.insert(item.id)
    }
}

// MARK: - Item Row
struct DiscoveryItemRow: View {
    let item: DiscoveryItem
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            Group {
                if let url = item.imageURL, let u = URL(string: url) {
                    AsyncImage(url: u) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure:
                            DSColor.surface
                                .overlay(Image(systemName: item.category.icon)
                                    .foregroundStyle(DSColor.textTertiary))
                        default: DSColor.surface.overlay(ProgressView())
                        }
                    }
                } else {
                    DSColor.surface
                        .overlay(Image(systemName: item.category.icon)
                            .foregroundStyle(DSColor.textTertiary))
                }
            }
            .frame(width: 72, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.brand).font(DSTypography.caption2).foregroundStyle(DSColor.textTertiary)
                Text(item.name).font(DSTypography.bodyMedium).foregroundStyle(DSColor.textPrimary).lineLimit(2)
                Text(item.formattedPrice).font(DSTypography.price).foregroundStyle(DSColor.accent)
            }

            Spacer()

            // Add button
            Button { onAdd() } label: {
                Image(systemName: isAdded ? "checkmark" : "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isAdded ? DSColor.success : .white)
                    .frame(width: 36, height: 36)
                    .background(isAdded ? DSColor.success.opacity(0.15) : DSColor.accent,
                                in: Circle())
            }
            .disabled(isAdded)
        }
        .padding(14)
        .background(DSColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
