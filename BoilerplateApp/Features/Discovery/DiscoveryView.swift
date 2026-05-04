import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm: DiscoveryViewModel = .init(service: DiscoveryService())
    @State private var selectedOutfit: DiscoveryOutfit?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Store filter bar
                storeFilterBar

                // Occasion + sort row
                occasionSortRow

                Divider().foregroundStyle(DSColor.border)

                // Feed
                ScrollView {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity).padding(.top, 80)
                    } else if vm.outfits.isEmpty {
                        EmptyStateView(icon: "magnifyingglass",
                                       title: "No Results",
                                       message: "Try adjusting your filters.")
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.outfits) { outfit in
                                Button { selectedOutfit = outfit } label: {
                                    DiscoveryOutfitCard(outfit: outfit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(DSColor.background)
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .task { await vm.load() }
            .sheet(item: $selectedOutfit) { outfit in
                OutfitDetailView(outfit: outfit)
                    .environmentObject(env)
            }
        }
    }

    // MARK: - Store Filter Bar
    private var storeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RetailStore.allCases) { store in
                    DSTag(label: store.rawValue,
                          isSelected: vm.selectedStores.contains(store)) {
                        vm.toggleStore(store)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Occasion + Sort Row
    private var occasionSortRow: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    DSTag(label: "All", isSelected: vm.selectedOccasion == nil) {
                        vm.selectOccasion(nil)
                    }
                    ForEach(OccasionTag.allCases) { tag in
                        DSTag(label: tag.rawValue, isSelected: vm.selectedOccasion == tag) {
                            vm.selectOccasion(vm.selectedOccasion == tag ? nil : tag)
                        }
                    }
                }
                .padding(.leading, 16)
            }

            Spacer()

            Menu {
                ForEach(DiscoverySortOption.allCases, id: \.self) { opt in
                    Button(opt.rawValue) { vm.applySort(opt) }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(vm.sortOption == .aiScore ? "Sort" : vm.sortOption.rawValue)
                        .lineLimit(1)
                }
                .font(DSTypography.caption)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.trailing, 16)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Discovery Outfit Card
struct DiscoveryOutfitCard: View {
    let outfit: DiscoveryOutfit

    var body: some View {
        DSOutfitCard {
            VStack(alignment: .leading, spacing: 14) {

                // Item thumbnails + badge
                HStack(alignment: .top, spacing: 10) {
                    HStack(spacing: 6) {
                        ForEach(outfit.items.prefix(4)) { item in
                            Group {
                                if let url = item.imageURL, let u = URL(string: url) {
                                    AsyncImage(url: u) { img in img.resizable().scaledToFill() }
                                        placeholder: { DSColor.surface }
                                } else {
                                    DSColor.surface
                                        .overlay(Image(systemName: item.category.icon)
                                            .foregroundStyle(DSColor.textTertiary))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    DSMatchBadge(percent: outfit.aiMatchPercent)
                }

                // Name + tags
                VStack(alignment: .leading, spacing: 6) {
                    Text(outfit.name)
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColor.textPrimary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(outfit.occasionTags) { tag in DSTag(label: tag.rawValue) }
                        }
                    }
                }

                // Price + CTA
                HStack {
                    Text("Complete look from \(outfit.formattedTotal)")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.textSecondary)
                    Spacer()
                    Text("Buy All →")
                        .font(DSTypography.label)
                        .foregroundStyle(DSColor.accent)
                }
            }
            .padding(16)
        }
    }
}
