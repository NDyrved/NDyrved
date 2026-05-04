import Foundation

/// Returns curated outfit suggestions from supported retailers.
/// Currently backed by structured mock data — swap `fetchOutfits()` for a real API call later.
final class DiscoveryService {

    func fetchOutfits(stores: Set<RetailStore> = [],
                      occasion: OccasionTag? = nil,
                      sort: DiscoverySortOption = .aiScore) -> [DiscoveryOutfit] {

        var results = catalogue
        if !stores.isEmpty { results = results.filter { stores.contains($0.store) } }
        if let occ = occasion { results = results.filter { $0.occasionTags.contains(occ) } }

        switch sort {
        case .aiScore:  results.sort { $0.aiMatchPercent > $1.aiMatchPercent }
        case .priceLow: results.sort { $0.totalPrice < $1.totalPrice }
        case .priceHigh:results.sort { $0.totalPrice > $1.totalPrice }
        case .newest:   break   // in a real API, sort by date
        }
        return results
    }

    // MARK: - Mock Catalogue
    private var catalogue: [DiscoveryOutfit] = [
        .init(id: UUID(), name: "Linen & Leather Edit",
              items: [
                .init(id: UUID(), name: "Linen Blazer",    brand: "Everlane", store: .cos,    price: 159, currency: "€", category: .outerwear, imageURL: nil, productURL: "https://cos.com"),
                .init(id: UUID(), name: "Oxford Shirt",    brand: "Theory",   store: .cos,    price: 89,  currency: "€", category: .top,       imageURL: nil, productURL: "https://cos.com"),
                .init(id: UUID(), name: "Navy Trousers",   brand: "Acne",     store: .cos,    price: 195, currency: "€", category: .bottom,    imageURL: nil, productURL: "https://cos.com"),
                .init(id: UUID(), name: "Tan Loafers",     brand: "G.H. Bass",store: .mango,  price: 129, currency: "€", category: .shoes,     imageURL: nil, productURL: "https://mango.com"),
              ],
              occasionTags: [.smartCasual, .work],
              aiMatchPercent: 94, store: .cos, colorPalette: ["#D4B896","#1E3A5F","#F5EFE6","#C4965A"]),

        .init(id: UUID(), name: "Downtown Weekend",
              items: [
                .init(id: UUID(), name: "Oversized Tee",   brand: "H&M",   store: .hm,    price: 19,  currency: "€", category: .top,       imageURL: nil, productURL: "https://hm.com"),
                .init(id: UUID(), name: "Straight Jeans",  brand: "Zara",  store: .zara,  price: 49,  currency: "€", category: .bottom,    imageURL: nil, productURL: "https://zara.com"),
                .init(id: UUID(), name: "White Sneakers",  brand: "ASOS",  store: .asos,  price: 55,  currency: "€", category: .shoes,     imageURL: nil, productURL: "https://asos.com"),
                .init(id: UUID(), name: "Canvas Tote",     brand: "Mango", store: .mango, price: 35,  currency: "€", category: .accessory, imageURL: nil, productURL: "https://mango.com"),
              ],
              occasionTags: [.casual, .weekend],
              aiMatchPercent: 88, store: .zara, colorPalette: ["#FFFFFF","#3D5A80","#F7F3EE","#E8E0D5"]),

        .init(id: UUID(), name: "The Linen Sunday Edit",
              items: [
                .init(id: UUID(), name: "Linen Shirt",     brand: "& Other Stories", store: .otherStories, price: 75, currency: "€", category: .top,    imageURL: nil, productURL: "https://stories.com"),
                .init(id: UUID(), name: "Olive Trousers",  brand: "COS",             store: .cos,          price: 99, currency: "€", category: .bottom, imageURL: nil, productURL: "https://cos.com"),
                .init(id: UUID(), name: "Leather Sandals", brand: "Mango",           store: .mango,        price: 79, currency: "€", category: .shoes,  imageURL: nil, productURL: "https://mango.com"),
              ],
              occasionTags: [.casual, .weekend],
              aiMatchPercent: 91, store: .otherStories, colorPalette: ["#C8B89A","#5B6F47","#E8DFD0"]),

        .init(id: UUID(), name: "Monochrome Work Look",
              items: [
                .init(id: UUID(), name: "Navy Blazer",     brand: "Zara",  store: .zara, price: 89,  currency: "€", category: .outerwear, imageURL: nil, productURL: "https://zara.com"),
                .init(id: UUID(), name: "Navy Trousers",   brand: "Zara",  store: .zara, price: 59,  currency: "€", category: .bottom,    imageURL: nil, productURL: "https://zara.com"),
                .init(id: UUID(), name: "White Shirt",     brand: "H&M",   store: .hm,   price: 29,  currency: "€", category: .top,       imageURL: nil, productURL: "https://hm.com"),
              ],
              occasionTags: [.work, .formal],
              aiMatchPercent: 79, store: .zara, colorPalette: ["#1E3A5F","#1E3A5F","#FFFFFF"]),

        .init(id: UUID(), name: "Urban Explorer",
              items: [
                .init(id: UUID(), name: "Cargo Trousers",  brand: "Bershka", store: .bershka, price: 39, currency: "€", category: .bottom, imageURL: nil, productURL: "https://bershka.com"),
                .init(id: UUID(), name: "Graphic Tee",     brand: "Bershka", store: .bershka, price: 19, currency: "€", category: .top,    imageURL: nil, productURL: "https://bershka.com"),
                .init(id: UUID(), name: "Chunky Sneakers", brand: "ASOS",    store: .asos,    price: 75, currency: "€", category: .shoes,  imageURL: nil, productURL: "https://asos.com"),
              ],
              occasionTags: [.casual, .weekend],
              aiMatchPercent: 82, store: .bershka, colorPalette: ["#6B7A5E","#2C2C2C","#E8E8E8"]),

        .init(id: UUID(), name: "Smart Evening",
              items: [
                .init(id: UUID(), name: "Silk Blouse",     brand: "& Other Stories", store: .otherStories, price: 95, currency: "€", category: .top,       imageURL: nil, productURL: "https://stories.com"),
                .init(id: UUID(), name: "Tailored Pants",  brand: "COS",             store: .cos,          price: 119, currency: "€", category: .bottom,   imageURL: nil, productURL: "https://cos.com"),
                .init(id: UUID(), name: "Block Heels",     brand: "Mango",           store: .mango,        price: 99, currency: "€", category: .shoes,     imageURL: nil, productURL: "https://mango.com"),
                .init(id: UUID(), name: "Clutch Bag",      brand: "Mango",           store: .mango,        price: 49, currency: "€", category: .accessory, imageURL: nil, productURL: "https://mango.com"),
              ],
              occasionTags: [.evening, .formal, .smartCasual],
              aiMatchPercent: 96, store: .cos, colorPalette: ["#D4A5C9","#2C2C2C","#8B6D8B","#C4965A"]),

        .init(id: UUID(), name: "Minimal Weekend",
              items: [
                .init(id: UUID(), name: "White Linen Shirt",brand: "H&M",  store: .hm,   price: 29, currency: "€", category: .top,    imageURL: nil, productURL: "https://hm.com"),
                .init(id: UUID(), name: "Beige Chinos",     brand: "Zara", store: .zara, price: 49, currency: "€", category: .bottom, imageURL: nil, productURL: "https://zara.com"),
                .init(id: UUID(), name: "Suede Loafers",    brand: "ASOS", store: .asos, price: 65, currency: "€", category: .shoes,  imageURL: nil, productURL: "https://asos.com"),
              ],
              occasionTags: [.casual, .weekend, .smartCasual],
              aiMatchPercent: 87, store: .hm, colorPalette: ["#F5EFE6","#D4B896","#8B7355"]),
    ]
}
