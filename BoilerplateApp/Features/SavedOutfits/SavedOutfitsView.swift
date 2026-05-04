import SwiftUI

struct SavedOutfitsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var showPaywall = false
    @State private var outfitToDelete: Outfit?
    @State private var showDeleteAlert = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if !env.isPremium {
                    premiumGate
                } else if env.outfitStore.outfits.isEmpty {
                    EmptyStateView(
                        icon: "heart.slash",
                        title: "No Saved Outfits",
                        message: "Build an outfit in the Try On tab and save it here."
                    )
                } else {
                    outfitGrid
                }
            }
            .navigationTitle("Saved Outfits")
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(env)
            }
            .alert("Delete Outfit?", isPresented: $showDeleteAlert, presenting: outfitToDelete) { outfit in
                Button("Delete", role: .destructive) { env.outfitStore.deleteOutfit(outfit) }
                Button("Cancel", role: .cancel) {}
            } message: { outfit in
                Text("\"\(outfit.name)\" will be permanently removed.")
            }
        }
    }

    // MARK: - Premium Gate
    private var premiumGate: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(DSColor.accent)
            Text("Premium Feature")
                .font(.title2.bold())
            Text("Saving outfits is available on the Premium plan.")
                .font(DSTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Upgrade to Premium") { showPaywall = true }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Grid
    private var outfitGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(env.outfitStore.outfits) { outfit in
                    OutfitCard(outfit: outfit)
                        .contextMenu {
                            Button(outfit.isFavourite ? "Unfavourite" : "Favourite",
                                   systemImage: outfit.isFavourite ? "heart.slash" : "heart") {
                                env.outfitStore.updateOutfit(outfit, isFavourite: !outfit.isFavourite)
                            }
                            Divider()
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                outfitToDelete = outfit
                                showDeleteAlert = true
                            }
                        }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Outfit Card
struct OutfitCard: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Body photo thumbnail
            Group {
                if let data = outfit.bodyPhotoData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                } else {
                    DSColor.card
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary.opacity(0.4))
                        )
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .topTrailing) {
                if outfit.isFavourite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .padding(8)
                }
            }

            // Metadata
            VStack(alignment: .leading, spacing: 2) {
                Text(outfit.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(outfit.items.count) item\(outfit.items.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
    }
}
