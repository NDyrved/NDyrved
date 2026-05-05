import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm = DiscoveryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // URL input card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Paste a product link from any store")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textSecondary)

                        HStack(spacing: 10) {
                            TextField("https://...", text: $vm.urlInput)
                                .font(DSTypography.body)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .keyboardType(.URL)
                                .submitLabel(.search)
                                .onSubmit { Task { await vm.fetchProduct(outfitStore: env.outfitStore) } }

                            // Paste from clipboard
                            Button {
                                if let str = UIPasteboard.general.string {
                                    vm.urlInput = str
                                    Task { await vm.fetchProduct(outfitStore: env.outfitStore) }
                                }
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                                    .foregroundStyle(DSColor.accent)
                            }

                            // Fetch button
                            Button {
                                Task { await vm.fetchProduct(outfitStore: env.outfitStore) }
                            } label: {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(DSColor.accent)
                            }
                            .disabled(vm.urlInput.isEmpty)
                        }
                        .padding(14)
                        .background(DSColor.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // State
                    switch vm.fetchState {
                    case .idle:
                        idlePlaceholder
                    case .loading:
                        ProgressView("Fetching product…")
                            .padding(.top, 60)
                    case .success(let meta, let url):
                        ProductResultCard(meta: meta, url: url, vm: vm)
                            .padding(.horizontal, 20)
                    case .error(let msg):
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundStyle(.orange)
                            Text(msg)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.textSecondary)
                                .multilineTextAlignment(.center)
                            Button("Try Again") { vm.reset() }
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.accent)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(DSColor.background)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $vm.showTryOn) {
                if let item = vm.tryOnItem {
                    TryOnView(initialItems: [item]).environmentObject(env)
                }
            }
        }
    }

    private var idlePlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundStyle(DSColor.accent.opacity(0.5))
            Text("Paste a link from H&M, ASOS, Zara\nor any other store")
                .font(DSTypography.body)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// MARK: - Product Result Card
private struct ProductResultCard: View {
    @EnvironmentObject private var env: AppEnvironment
    let meta: FetchedClothingMeta
    let url: String
    @ObservedObject var vm: DiscoveryViewModel

    var body: some View {
        VStack(spacing: 0) {

            // Product image
            Group {
                if let data = meta.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if let imageURL = meta.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: DSColor.card.overlay(ProgressView())
                        }
                    }
                } else {
                    DSColor.card
                        .overlay(Image(systemName: "photo").foregroundStyle(DSColor.textTertiary))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .clipped()

            // Info + actions
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    let item = vm.makeClothingItem(from: meta, url: url)
                    Text(item.brand)
                        .font(DSTypography.caption2)
                        .foregroundStyle(DSColor.textTertiary)
                    Text(meta.productName)
                        .font(DSTypography.bodyMedium)
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(2)
                }

                // 4 action buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                    // Wishlist — toggle add/remove
                    ActionButton(
                        icon: vm.savedToWishlist ? "heart.fill" : "heart",
                        label: vm.savedToWishlist ? "Wishlisted" : "Wishlist",
                        tint: .pink,
                        filled: vm.savedToWishlist
                    ) {
                        if vm.savedToWishlist {
                            env.outfitStore.removeFromWishlist(sourceURL: url)
                            vm.savedToWishlist = false
                        } else {
                            let item = vm.makeClothingItem(from: meta, url: url)
                            env.outfitStore.saveToWishlist(item)
                            vm.savedToWishlist = true
                        }
                    }

                    // Wardrobe — toggle add/remove
                    ActionButton(
                        icon: vm.savedToWardrobe ? "checkmark" : "tshirt",
                        label: vm.savedToWardrobe ? "Saved" : "Wardrobe",
                        tint: DSColor.accent,
                        filled: vm.savedToWardrobe
                    ) {
                        if vm.savedToWardrobe {
                            env.outfitStore.removeFromWardrobe(sourceURL: url)
                            vm.savedToWardrobe = false
                        } else {
                            let item = vm.makeClothingItem(from: meta, url: url)
                            env.outfitStore.saveClothingItem(item)
                            vm.savedToWardrobe = true
                        }
                    }

                    // Try On
                    ActionButton(icon: "person.fill.viewfinder", label: "Try On", tint: .blue) {
                        vm.tryOnItem = vm.makeClothingItem(from: meta, url: url)
                        vm.showTryOn = true
                    }

                    // Buy
                    ActionButton(icon: "bag", label: "Buy", tint: DSColor.accent, primary: true) {
                        if let affiliateURL = vm.affiliateURL(for: url) {
                            UIApplication.shared.open(affiliateURL)
                        }
                    }
                }

                Button("Search another product") { vm.reset() }
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColor.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
            .background(DSColor.card)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Action Button
private struct ActionButton: View {
    let icon: String
    let label: String
    var tint: Color = .primary
    var filled: Bool = false
    var primary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(DSTypography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(primary ? .white : (filled ? tint : tint))
            .background(
                primary ? tint :
                filled  ? tint.opacity(0.12) :
                          DSColor.background,
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(primary ? Color.clear : tint.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
