import Foundation
import SwiftData
import UIKit

/// Wraps SwiftData operations for Outfit persistence.
@MainActor
final class OutfitStore: ObservableObject {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    @Published var outfits: [Outfit] = []

    init() {
        let schema = Schema([Outfit.self, ClothingItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        modelContext = modelContainer.mainContext
        fetchOutfits()
    }

    func fetchOutfits() {
        let descriptor = FetchDescriptor<Outfit>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        outfits = (try? modelContext.fetch(descriptor)) ?? []
    }

    func saveOutfit(_ outfit: Outfit) {
        modelContext.insert(outfit)
        try? modelContext.save()
        fetchOutfits()
    }

    func deleteOutfit(_ outfit: Outfit) {
        modelContext.delete(outfit)
        try? modelContext.save()
        fetchOutfits()
    }

    func updateOutfit(_ outfit: Outfit, name: String? = nil, isFavourite: Bool? = nil) {
        if let name       { outfit.name        = name       }
        if let isFavourite { outfit.isFavourite = isFavourite }
        outfit.updatedAt = .now
        try? modelContext.save()
        fetchOutfits()
    }

    // MARK: - Standalone Clothing Items (wardrobe)
    func allClothingItems() -> [ClothingItem] {
        let descriptor = FetchDescriptor<ClothingItem>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func saveClothingItem(_ item: ClothingItem) {
        modelContext.insert(item)
        try? modelContext.save()
    }

    func deleteClothingItem(_ item: ClothingItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }

    func wishlistItems() -> [ClothingItem] {
        let descriptor = FetchDescriptor<ClothingItem>(
            predicate: #Predicate { $0.isWishlisted == true },
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func saveToWishlist(_ item: ClothingItem) {
        item.isWishlisted = true
        modelContext.insert(item)
        try? modelContext.save()
    }

    // MARK: - Try-On Count (free tier gating)
    private let tryOnCountKey = "tryOnCount"
    private let tryOnMonthKey = "tryOnMonth"

    var tryOnCountThisMonth: Int {
        let stored = UserDefaults.standard.integer(forKey: tryOnCountKey)
        let storedMonth = UserDefaults.standard.string(forKey: tryOnMonthKey) ?? ""
        let currentMonth = currentMonthString()
        if storedMonth != currentMonth { return 0 }
        return stored
    }

    func incrementTryOnCount() {
        let month = currentMonthString()
        let stored = UserDefaults.standard.string(forKey: tryOnMonthKey) ?? ""
        if stored != month {
            UserDefaults.standard.set(month, forKey: tryOnMonthKey)
            UserDefaults.standard.set(1, forKey: tryOnCountKey)
        } else {
            let count = UserDefaults.standard.integer(forKey: tryOnCountKey)
            UserDefaults.standard.set(count + 1, forKey: tryOnCountKey)
        }
    }

    private func currentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}
