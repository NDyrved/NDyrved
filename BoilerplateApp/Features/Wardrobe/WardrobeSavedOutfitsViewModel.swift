import Foundation

@MainActor
final class WardrobeSavedOutfitsViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var selectedTag: OccasionTag? = nil

    private let store: OutfitStore

    init(store: OutfitStore) {
        self.store = store
        refresh()
    }

    func refresh() { outfits = store.outfits }

    var filteredOutfits: [Outfit] {
        guard let tag = selectedTag else { return outfits }
        return outfits.filter { $0.tags.contains(tag) }
    }

    var savedLooksCount: Int { outfits.count }
    var totalItemsCount: Int { outfits.flatMap(\.items).count }
    var completeOutfitsCount: Int {
        outfits.filter { o in
            let cats = Set(o.items.map(\.category))
            return (cats.contains(.top) || cats.contains(.dress)) &&
                   (cats.contains(.bottom) || cats.contains(.dress)) &&
                    cats.contains(.shoes)
        }.count
    }

    func toggleFavourite(_ outfit: Outfit) {
        store.updateOutfit(outfit, isFavourite: !outfit.isFavourite)
        refresh()
    }

    func delete(_ outfit: Outfit) {
        store.deleteOutfit(outfit)
        refresh()
    }
}
