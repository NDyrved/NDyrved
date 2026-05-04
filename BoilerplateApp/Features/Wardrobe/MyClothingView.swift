import SwiftUI

struct MyClothingView: View {
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm: MyClothingViewModel = .init(store: .init())
    @State private var showAddClothing = false
    @State private var itemToDelete: ClothingItem?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Stats header
                statsHeader

                // Search
                DSTextField(title: "Search brand or item", text: $vm.searchText, icon: "magnifyingglass")
                    .padding(.horizontal, 20)

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        DSTag(label: "All", isSelected: vm.selectedCategory == nil) {
                            vm.selectedCategory = nil
                        }
                        ForEach(ClothingCategory.allCases, id: \.self) { cat in
                            DSTag(label: cat.rawValue, isSelected: vm.selectedCategory == cat) {
                                vm.selectedCategory = vm.selectedCategory == cat ? nil : cat
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Grid
                if vm.filteredItems.isEmpty {
                    EmptyStateView(
                        icon: "tshirt",
                        title: "No Items Yet",
                        message: "Add clothing from the Builder tab by pasting a product URL."
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.filteredItems) { item in
                            ClothingItemCard(item: item)
                                .contextMenu {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        itemToDelete = item
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
        .confirmationDialog("Delete item?", isPresented: .constant(itemToDelete != nil), presenting: itemToDelete) { item in
            Button("Delete \"\(item.productName.isEmpty ? "Item" : item.productName)\"", role: .destructive) {
                vm.delete(item)
                itemToDelete = nil
            }
            Button("Cancel", role: .cancel) { itemToDelete = nil }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 0) {
            statCell(value: "\(vm.items.count)", label: "Items")
            Divider().frame(height: 32)
            statCell(value: "\(vm.items.filter { $0.category == .top || $0.category == .dress }.count)", label: "Tops")
            Divider().frame(height: 32)
            statCell(value: "\(vm.items.filter { $0.category == .bottom }.count)", label: "Bottoms")
            Divider().frame(height: 32)
            statCell(value: "\(vm.items.filter { $0.category == .shoes }.count)", label: "Shoes")
        }
        .padding(.vertical, 16)
        .background(DSColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(DSTypography.title2).foregroundStyle(DSColor.textPrimary)
            Text(label).font(DSTypography.caption).foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Clothing Item Card
struct ClothingItemCard: View {
    let item: ClothingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Thumbnail
            Group {
                if let data = item.imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
                } else {
                    DSColor.surface
                        .overlay(Image(systemName: item.category.icon)
                            .foregroundStyle(DSColor.textTertiary).font(.title3))
                }
            }
            .frame(height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Label
            VStack(alignment: .leading, spacing: 1) {
                if !item.brand.isEmpty {
                    Text(item.brand).font(DSTypography.caption2).foregroundStyle(DSColor.textTertiary)
                }
                Text(item.productName.isEmpty ? item.category.rawValue : item.productName)
                    .font(DSTypography.caption).foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 2)
        }
    }
}
