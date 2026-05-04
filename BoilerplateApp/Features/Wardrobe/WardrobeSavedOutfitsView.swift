import SwiftUI

struct WardrobeSavedOutfitsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm: WardrobeSavedOutfitsViewModel = .init(store: .init())
    @State private var showPaywall = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Stats row
                statsRow

                // Tag filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        DSTag(label: "All", isSelected: vm.selectedTag == nil) { vm.selectedTag = nil }
                        ForEach(OccasionTag.allCases) { tag in
                            DSTag(label: tag.rawValue, isSelected: vm.selectedTag == tag) {
                                vm.selectedTag = vm.selectedTag == tag ? nil : tag
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if !env.isPremium {
                    premiumGate
                } else if vm.filteredOutfits.isEmpty {
                    EmptyStateView(
                        icon: "heart.slash",
                        title: "No Saved Outfits",
                        message: "Build and save outfits in the Builder tab."
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(vm.filteredOutfits) { outfit in
                            WardrobeOutfitCard(outfit: outfit)
                                .contextMenu {
                                    Button(outfit.isFavourite ? "Unfavourite" : "Favourite",
                                           systemImage: outfit.isFavourite ? "heart.slash" : "heart") {
                                        vm.toggleFavourite(outfit)
                                    }
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        vm.delete(outfit)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .background(DSColor.background)
        .onAppear { vm.refresh() }
        .sheet(isPresented: $showPaywall) { PaywallView().environmentObject(env) }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell("\(vm.savedLooksCount)", "Saved Looks")
            Divider().frame(height: 32)
            statCell("\(vm.totalItemsCount)", "Items")
            Divider().frame(height: 32)
            statCell("\(vm.completeOutfitsCount)", "Complete")
        }
        .padding(.vertical, 16)
        .background(DSColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func statCell(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(DSTypography.title2).foregroundStyle(DSColor.textPrimary)
            Text(label).font(DSTypography.caption).foregroundStyle(DSColor.textSecondary)
        }.frame(maxWidth: .infinity)
    }

    private var premiumGate: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill").font(.system(size: 40)).foregroundStyle(DSColor.accent)
            Text("Premium Feature").font(DSTypography.title2).foregroundStyle(DSColor.textPrimary)
            Text("Save and revisit outfits with a Premium plan.")
                .font(DSTypography.body).foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            Button("Upgrade to Premium") { showPaywall = true }
                .buttonStyle(PrimaryButtonStyle()).padding(.horizontal, 40)
        }
        .padding(.top, 40)
    }
}

// MARK: - Outfit Card
struct WardrobeOutfitCard: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Item collage
            let data = outfit.items.prefix(4).map(\.imageData)
            let icons = outfit.items.prefix(4).map { $0.category.icon }
            DSItemThumbnailStrip(imageDataList: Array(data), icons: Array(icons), height: 72)

            // Name + favourite
            HStack {
                Text(outfit.name).font(DSTypography.label).foregroundStyle(DSColor.textPrimary).lineLimit(1)
                Spacer()
                if outfit.isFavourite {
                    Image(systemName: "heart.fill").foregroundStyle(.red).font(.caption)
                }
            }

            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(outfit.tags) { tag in
                        DSTag(label: tag.rawValue)
                    }
                }
            }

            // Style score
            if outfit.styleScore > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles").font(.caption2).foregroundStyle(DSColor.accent)
                    Text("Score \(outfit.styleScore)").font(DSTypography.caption2).foregroundStyle(DSColor.textSecondary)
                }
            }
        }
        .padding(14)
        .background(DSColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}
