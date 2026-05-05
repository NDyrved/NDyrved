import SwiftUI

struct WardrobeView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var selectedSection = 0

    private let sections = ["My Clothing", "Saved Outfits", "Wishlist"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(sections.indices, id: \.self) { i in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedSection = i }
                            } label: {
                                VStack(spacing: 6) {
                                    Text(sections[i])
                                        .font(selectedSection == i ? DSTypography.bodyMedium : DSTypography.body)
                                        .foregroundStyle(selectedSection == i ? DSColor.textPrimary : DSColor.textSecondary)
                                        .padding(.horizontal, 16)
                                    Rectangle()
                                        .fill(selectedSection == i ? DSColor.accent : .clear)
                                        .frame(height: 2)
                                        .padding(.horizontal, 8)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.top, 4)

                Divider().foregroundStyle(DSColor.border)

                // Content
                TabView(selection: $selectedSection) {
                    MyClothingView().tag(0)
                    WardrobeSavedOutfitsView().tag(1)
                    WishlistView().tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: selectedSection)
            }
            .background(DSColor.background)
            .navigationTitle("Wardrobe")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
