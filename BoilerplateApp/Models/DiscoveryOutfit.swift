import Foundation

// MARK: - Supported Stores
enum RetailStore: String, CaseIterable, Identifiable {
    case zara          = "Zara"
    case hm            = "H&M"
    case bershka       = "Bershka"
    case mango         = "Mango"
    case asos          = "ASOS"
    case otherStories  = "& Other Stories"
    case cos           = "COS"

    var id: String { rawValue }
}

// MARK: - Discovery Item
struct DiscoveryItem: Identifiable {
    let id: UUID
    let name: String
    let brand: String
    let store: RetailStore
    let price: Double
    let currency: String
    let category: ClothingCategory
    let imageURL: String?           // remote URL — shown with AsyncImage
    let productURL: String

    var formattedPrice: String { "\(currency)\(String(format: "%.2f", price))" }
}

// MARK: - Discovery Outfit
struct DiscoveryOutfit: Identifiable {
    let id: UUID
    let name: String
    let items: [DiscoveryItem]
    let occasionTags: [OccasionTag]
    let aiMatchPercent: Int
    let store: RetailStore          // primary store for this outfit
    let colorPalette: [String]

    var totalPrice: Double { items.map(\.price).reduce(0, +) }
    var formattedTotal: String {
        guard let first = items.first else { return "" }
        return "\(first.currency)\(String(format: "%.2f", totalPrice))"
    }
}

// MARK: - Sort Option
enum DiscoverySortOption: String, CaseIterable {
    case aiScore      = "AI Score"
    case priceLow     = "Price: Low–High"
    case priceHigh    = "Price: High–Low"
    case newest       = "Newest"
}
