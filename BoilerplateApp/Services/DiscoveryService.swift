import Foundation

/// Returns curated outfit suggestions from supported retailers.
/// Currently backed by structured mock data — swap `fetchOutfits()` for a real API call later.
/// Images: reliable Unsplash fashion CDN (stable, fast). Replace with real brand OG images via
/// ClothingFetchService when a backend catalogue is available.
/// Product URLs: deep-link search pages on each brand site for the specific item type.
final class DiscoveryService {

    // Single-store filter (nil = show all)
    func fetchOutfits(store: RetailStore? = nil,
                      occasion: OccasionTag? = nil,
                      sort: DiscoverySortOption = .aiScore) -> [DiscoveryOutfit] {

        var results = catalogue
        if let s = store { results = results.filter { $0.store == s } }
        if let occ = occasion { results = results.filter { $0.occasionTags.contains(occ) } }

        switch sort {
        case .aiScore:   results.sort { $0.aiMatchPercent > $1.aiMatchPercent }
        case .priceLow:  results.sort { $0.totalPrice < $1.totalPrice }
        case .priceHigh: results.sort { $0.totalPrice > $1.totalPrice }
        case .newest:    break
        }
        return results
    }

    // MARK: - Mock Catalogue
    // productURL: deep-links to brand search/category pages for the specific item
    private var catalogue: [DiscoveryOutfit] = [

        .init(id: UUID(), name: "Linen & Leather Edit",
              items: [
                .init(id: UUID(), name: "Relaxed Linen Blazer",
                      brand: "COS", store: .cos, price: 159, currency: "€", category: .outerwear,
                      imageURL: "https://images.unsplash.com/photo-1594938298603-c8148c4bccb8?w=400&q=80",
                      productURL: "https://www.cos.com/en_eur/search.html?q=linen+blazer"),
                .init(id: UUID(), name: "Oxford Poplin Shirt",
                      brand: "COS", store: .cos, price: 89, currency: "€", category: .top,
                      imageURL: "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400&q=80",
                      productURL: "https://www.cos.com/en_eur/search.html?q=oxford+poplin+shirt+white"),
                .init(id: UUID(), name: "Tapered Suit Trousers",
                      brand: "COS", store: .cos, price: 119, currency: "€", category: .bottom,
                      imageURL: "https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&q=80",
                      productURL: "https://www.cos.com/en_eur/search.html?q=tapered+trousers+navy"),
                .init(id: UUID(), name: "Leather Loafers",
                      brand: "COS", store: .cos, price: 145, currency: "€", category: .shoes,
                      imageURL: "https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=400&q=80",
                      productURL: "https://www.cos.com/en_eur/search.html?q=leather+loafers"),
              ],
              occasionTags: [.smartCasual, .work],
              aiMatchPercent: 94, store: .cos,
              colorPalette: ["#D4B896","#1E3A5F","#F5EFE6","#C4965A"]),

        .init(id: UUID(), name: "Downtown Weekend",
              items: [
                .init(id: UUID(), name: "Oversized Cotton Tee",
                      brand: "H&M", store: .hm, price: 14, currency: "€", category: .top,
                      imageURL: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&q=80",
                      productURL: "https://www2.hm.com/en_gb/search-results.html?q=oversized+t-shirt"),
                .init(id: UUID(), name: "Straight Regular Jeans",
                      brand: "H&M", store: .hm, price: 39, currency: "€", category: .bottom,
                      imageURL: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=400&q=80",
                      productURL: "https://www2.hm.com/en_gb/search-results.html?q=straight+jeans"),
                .init(id: UUID(), name: "Canvas Sneakers",
                      brand: "H&M", store: .hm, price: 29, currency: "€", category: .shoes,
                      imageURL: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80",
                      productURL: "https://www2.hm.com/en_gb/search-results.html?q=white+canvas+sneakers"),
                .init(id: UUID(), name: "Canvas Shopper Tote",
                      brand: "H&M", store: .hm, price: 17, currency: "€", category: .accessory,
                      imageURL: "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&q=80",
                      productURL: "https://www2.hm.com/en_gb/search-results.html?q=canvas+tote+bag"),
              ],
              occasionTags: [.casual, .weekend],
              aiMatchPercent: 88, store: .hm,
              colorPalette: ["#FFFFFF","#3D5A80","#F7F3EE","#E8E0D5"]),

        .init(id: UUID(), name: "The Linen Sunday Edit",
              items: [
                .init(id: UUID(), name: "Relaxed Linen Shirt",
                      brand: "& Other Stories", store: .otherStories, price: 75, currency: "€", category: .top,
                      imageURL: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&q=80",
                      productURL: "https://www.stories.com/en_eur/search/?q=linen+shirt"),
                .init(id: UUID(), name: "Wide-Leg Linen Trousers",
                      brand: "& Other Stories", store: .otherStories, price: 99, currency: "€", category: .bottom,
                      imageURL: "https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400&q=80",
                      productURL: "https://www.stories.com/en_eur/search/?q=wide+leg+trousers"),
                .init(id: UUID(), name: "Leather Strappy Sandals",
                      brand: "& Other Stories", store: .otherStories, price: 89, currency: "€", category: .shoes,
                      imageURL: "https://images.unsplash.com/photo-1603487742131-4160ec999306?w=400&q=80",
                      productURL: "https://www.stories.com/en_eur/search/?q=leather+sandals"),
              ],
              occasionTags: [.casual, .weekend],
              aiMatchPercent: 91, store: .otherStories,
              colorPalette: ["#C8B89A","#5B6F47","#E8DFD0"]),

        .init(id: UUID(), name: "Monochrome Work Look",
              items: [
                .init(id: UUID(), name: "Structured Blazer",
                      brand: "Zara", store: .zara, price: 89, currency: "€", category: .outerwear,
                      imageURL: "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&q=80",
                      productURL: "https://www.zara.com/dk/en/search?searchTerm=structured+blazer"),
                .init(id: UUID(), name: "Slim Suit Trousers",
                      brand: "Zara", store: .zara, price: 59, currency: "€", category: .bottom,
                      imageURL: "https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&q=80",
                      productURL: "https://www.zara.com/dk/en/search?searchTerm=slim+suit+trousers+navy"),
                .init(id: UUID(), name: "Oxford Dress Shirt",
                      brand: "Zara", store: .zara, price: 29, currency: "€", category: .top,
                      imageURL: "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400&q=80",
                      productURL: "https://www.zara.com/dk/en/search?searchTerm=oxford+shirt+white"),
                .init(id: UUID(), name: "Leather Oxford Shoes",
                      brand: "Zara", store: .zara, price: 79, currency: "€", category: .shoes,
                      imageURL: "https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=400&q=80",
                      productURL: "https://www.zara.com/dk/en/search?searchTerm=leather+oxford+shoes"),
              ],
              occasionTags: [.work, .formal],
              aiMatchPercent: 79, store: .zara,
              colorPalette: ["#1E3A5F","#1E3A5F","#FFFFFF"]),

        .init(id: UUID(), name: "Urban Explorer",
              items: [
                .init(id: UUID(), name: "Cargo Jogger Pants",
                      brand: "Bershka", store: .bershka, price: 35, currency: "€", category: .bottom,
                      imageURL: "https://images.unsplash.com/photo-1622519407650-3df9883f76a5?w=400&q=80",
                      productURL: "https://www.bershka.com/gb/man/-c1656842.html?term=cargo+trousers"),
                .init(id: UUID(), name: "Graphic Print Tee",
                      brand: "Bershka", store: .bershka, price: 17, currency: "€", category: .top,
                      imageURL: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400&q=80",
                      productURL: "https://www.bershka.com/gb/man/-c1656842.html?term=graphic+t-shirt"),
                .init(id: UUID(), name: "Platform Chunky Trainers",
                      brand: "Bershka", store: .bershka, price: 69, currency: "€", category: .shoes,
                      imageURL: "https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=400&q=80",
                      productURL: "https://www.bershka.com/gb/man/-c1656842.html?term=chunky+trainers"),
              ],
              occasionTags: [.casual, .weekend],
              aiMatchPercent: 82, store: .bershka,
              colorPalette: ["#6B7A5E","#2C2C2C","#E8E8E8"]),

        .init(id: UUID(), name: "Smart Evening",
              items: [
                .init(id: UUID(), name: "Satin Cami Blouse",
                      brand: "Mango", store: .mango, price: 79, currency: "€", category: .top,
                      imageURL: "https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=400&q=80",
                      productURL: "https://shop.mango.com/gb/women/shirts-blouses?fullPrice=false&s=satin+blouse"),
                .init(id: UUID(), name: "Straight Suit Trousers",
                      brand: "Mango", store: .mango, price: 89, currency: "€", category: .bottom,
                      imageURL: "https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&q=80",
                      productURL: "https://shop.mango.com/gb/women/trousers?s=straight+suit+trousers"),
                .init(id: UUID(), name: "Block-Heel Pumps",
                      brand: "Mango", store: .mango, price: 99, currency: "€", category: .shoes,
                      imageURL: "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&q=80",
                      productURL: "https://shop.mango.com/gb/women/shoes?s=block+heel+pumps"),
                .init(id: UUID(), name: "Mini Chain Shoulder Bag",
                      brand: "Mango", store: .mango, price: 59, currency: "€", category: .accessory,
                      imageURL: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&q=80",
                      productURL: "https://shop.mango.com/gb/women/bags?s=chain+shoulder+bag"),
              ],
              occasionTags: [.evening, .formal, .smartCasual],
              aiMatchPercent: 96, store: .mango,
              colorPalette: ["#D4A5C9","#2C2C2C","#8B6D8B","#C4965A"]),

        .init(id: UUID(), name: "Minimal Weekend",
              items: [
                .init(id: UUID(), name: "Oversized Linen Shirt",
                      brand: "ASOS", store: .asos, price: 35, currency: "€", category: .top,
                      imageURL: "https://images.unsplash.com/photo-1620799139507-2a76f79a2f4d?w=400&q=80",
                      productURL: "https://www.asos.com/search/?q=oversized+linen+shirt"),
                .init(id: UUID(), name: "Slim Stone Chinos",
                      brand: "ASOS", store: .asos, price: 45, currency: "€", category: .bottom,
                      imageURL: "https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&q=80",
                      productURL: "https://www.asos.com/search/?q=slim+chino+stone"),
                .init(id: UUID(), name: "Suede Tassel Loafers",
                      brand: "ASOS", store: .asos, price: 65, currency: "€", category: .shoes,
                      imageURL: "https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=400&q=80",
                      productURL: "https://www.asos.com/search/?q=suede+tassel+loafers"),
              ],
              occasionTags: [.casual, .weekend, .smartCasual],
              aiMatchPercent: 87, store: .asos,
              colorPalette: ["#F5EFE6","#D4B896","#8B7355"]),
    ]
}
