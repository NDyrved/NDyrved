import Foundation
import SwiftData

@MainActor
final class MyClothingViewModel: ObservableObject {
    @Published var items: [ClothingItem] = []
    @Published var selectedCategory: ClothingCategory? = nil
    @Published var searchText = ""

    private let store: OutfitStore

    init(store: OutfitStore) {
        self.store = store
        refresh()
    }

    func refresh() {
        items = store.allClothingItems()
    }

    var filteredItems: [ClothingItem] {
        var result = items
        if let cat = selectedCategory { result = result.filter { $0.category == cat } }
        if !searchText.isEmpty {
            result = result.filter {
                $0.productName.localizedCaseInsensitiveContains(searchText) ||
                $0.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result.sorted { $0.addedAt > $1.addedAt }
    }

    func delete(_ item: ClothingItem) {
        store.deleteClothingItem(item)
        refresh()
    }
}
