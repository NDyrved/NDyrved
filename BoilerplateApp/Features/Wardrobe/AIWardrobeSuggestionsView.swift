import SwiftUI

struct AIWardrobeSuggestionsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm: AIWardrobeSuggestionsViewModel = {
        let store = OutfitStore()
        return AIWardrobeSuggestionsViewModel(aiService: AIStyleService(), store: store)
    }()
    @State private var savedIDs = Set<UUID>()
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("AI Suggestions")
                        .font(DSTypography.title2)
                        .foregroundStyle(DSColor.textPrimary)
                    Text("Outfits built from items already in your wardrobe")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Occasion filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        DSTag(label: "All", isSelected: vm.selectedOccasion == nil) {
                            vm.selectedOccasion = nil
                            Task { await vm.generate() }
                        }
                        ForEach(OccasionTag.allCases) { tag in
                            DSTag(label: tag.rawValue, isSelected: vm.selectedOccasion == tag) {
                                vm.selectedOccasion = vm.selectedOccasion == tag ? nil : tag
                                Task { await vm.generate() }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if !env.isPremium {
                    premiumGate
                } else if vm.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Analysing your wardrobe…")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 60)
                } else if vm.suggestions.isEmpty {
                    EmptyStateView(
                        icon: "sparkles",
                        title: "Add More Items",
                        message: "Add at least 2 clothing items to your wardrobe to generate suggestions."
                    )
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(vm.suggestions) { suggestion in
                            AISuggestionCard(
                                suggestion: suggestion,
                                isSaved: savedIDs.contains(suggestion.id),
                                onSave: {
                                    vm.saveToWardrobe(suggestion, store: env.outfitStore, aiService: env.aiStyle)
                                    savedIDs.insert(suggestion.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .background(DSColor.background)
        .task { if env.isPremium { await vm.generate() } }
        .sheet(isPresented: $showPaywall) { PaywallView().environmentObject(env) }
    }

    private var premiumGate: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles").font(.system(size: 40)).foregroundStyle(DSColor.accent)
            Text("AI Suggestions").font(DSTypography.title2).foregroundStyle(DSColor.textPrimary)
            Text("Let AI build outfits from your wardrobe.\nAvailable on Premium.")
                .font(DSTypography.body).foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            Button("Upgrade to Premium") { showPaywall = true }
                .buttonStyle(PrimaryButtonStyle()).padding(.horizontal, 40)
        }
        .padding(.top, 40)
    }
}

// MARK: - AI Suggestion Card
struct AISuggestionCard: View {
    let suggestion: OutfitSuggestion
    let isSaved: Bool
    let onSave: () -> Void

    var body: some View {
        DSOutfitCard {
            VStack(alignment: .leading, spacing: 14) {

                // Item strip + match badge
                HStack(alignment: .top, spacing: 10) {
                    let data  = suggestion.items.prefix(4).map(\.imageData)
                    let icons = suggestion.items.prefix(4).map { $0.category.icon }
                    DSItemThumbnailStrip(imageDataList: Array(data), icons: Array(icons), height: 90)
                    DSMatchBadge(percent: suggestion.aiMatchPercent, size: .regular)
                }

                // Title + tags
                VStack(alignment: .leading, spacing: 6) {
                    Text(suggestion.title)
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColor.textPrimary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(suggestion.occasionTags) { tag in
                                DSTag(label: tag.rawValue)
                            }
                        }
                    }
                }

                // Colour palette
                if !suggestion.colorPalette.isEmpty {
                    HStack(spacing: 8) {
                        Text("Palette").font(DSTypography.caption2).foregroundStyle(DSColor.textTertiary)
                        DSColorPaletteStrip(hexColors: suggestion.colorPalette)
                    }
                }

                // Save button
                if isSaved {
                    Button("Saved to Wardrobe") { onSave() }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(true)
                } else {
                    Button("Save Look") { onSave() }
                        .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(16)
        }
    }
}
