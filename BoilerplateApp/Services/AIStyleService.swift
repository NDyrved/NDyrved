import Foundation
import SwiftUI

// MARK: - Suggestion Model
struct OutfitSuggestion: Identifiable {
    let id: UUID
    let items: [ClothingItem]
    let occasionTags: [OccasionTag]
    let aiMatchPercent: Int
    let colorPalette: [String]      // hex strings
    let title: String
}

// MARK: - AI Style Service
/// Pure-Swift local engine that analyses the user's wardrobe and generates
/// outfit suggestions. No external API — all logic is deterministic.
final class AIStyleService {

    // MARK: - Public API
    func generateSuggestions(from items: [ClothingItem],
                              occasion: OccasionTag? = nil) -> [OutfitSuggestion] {
        guard items.count >= 2 else { return [] }

        // Group by category
        let tops       = items.filter { $0.category == .top || $0.category == .dress || $0.category == .outerwear }
        let bottoms    = items.filter { $0.category == .bottom }
        let shoes      = items.filter { $0.category == .shoes }
        let accessories = items.filter { $0.category == .accessory }

        var suggestions: [OutfitSuggestion] = []

        // Generate combos: top + bottom + (optional shoes) + (optional accessory)
        for top in tops.prefix(4) {
            for bottom in bottoms.prefix(4) {
                guard top.id != bottom.id else { continue }
                var combo: [ClothingItem] = [top, bottom]
                if let shoe = bestMatch(for: combo, from: shoes) { combo.append(shoe) }
                if let acc  = bestMatch(for: combo, from: accessories) { combo.append(acc) }

                let match  = computeMatchScore(combo)
                let occ    = inferOccasion(combo)
                let palette = combo.map(\.colorHex)
                let title   = suggestTitle(combo, occasion: occ.first)

                suggestions.append(OutfitSuggestion(
                    id: UUID(),
                    items: combo,
                    occasionTags: occ,
                    aiMatchPercent: match,
                    colorPalette: palette,
                    title: title
                ))
            }
        }

        // Dress outfits
        for dress in items.filter({ $0.category == .dress }).prefix(3) {
            var combo: [ClothingItem] = [dress]
            if let shoe = bestMatch(for: combo, from: shoes) { combo.append(shoe) }
            if let acc  = bestMatch(for: combo, from: accessories) { combo.append(acc) }
            let match   = computeMatchScore(combo)
            let occ     = inferOccasion(combo)
            suggestions.append(OutfitSuggestion(
                id: UUID(),
                items: combo,
                occasionTags: occ,
                aiMatchPercent: match,
                colorPalette: combo.map(\.colorHex),
                title: suggestTitle(combo, occasion: occ.first)
            ))
        }

        let filtered = occasion == nil
            ? suggestions
            : suggestions.filter { $0.occasionTags.contains(occasion!) }

        return filtered
            .sorted { $0.aiMatchPercent > $1.aiMatchPercent }
            .prefix(12)
            .map { $0 }
    }

    // MARK: - Score Computation

    /// Combines colour harmony + category completeness into 0-100.
    private func computeMatchScore(_ items: [ClothingItem]) -> Int {
        let harmony     = colourHarmonyScore(items)       // 0-50
        let completeness = categoryCompletenessScore(items) // 0-30
        let variety     = min(items.count * 5, 20)        // 0-20
        let raw         = harmony + completeness + variety
        // Add deterministic jitter based on item IDs to avoid all scores looking the same
        let jitter      = abs(items.map { $0.id.hashValue }.reduce(0, +)) % 7
        return min(raw + jitter, 99)
    }

    private func colourHarmonyScore(_ items: [ClothingItem]) -> Int {
        let groups = items.map { colourGroup($0.colorHex) }
        let uniqueGroups = Set(groups)

        // Monochromatic or neutral-dominant = high harmony
        if uniqueGroups.count == 1                         { return 48 }
        if uniqueGroups.contains(.neutral) && uniqueGroups.count == 2 { return 44 }
        if uniqueGroups.count == 2                         { return 38 }
        return 28
    }

    private func categoryCompletenessScore(_ items: [ClothingItem]) -> Int {
        let cats = Set(items.map(\.category))
        var score = 0
        if cats.contains(.top) || cats.contains(.dress) || cats.contains(.outerwear) { score += 10 }
        if cats.contains(.bottom) || cats.contains(.dress)                           { score += 10 }
        if cats.contains(.shoes)                                                      { score += 7 }
        if cats.contains(.accessory)                                                  { score += 3 }
        return score
    }

    // MARK: - Colour Grouping

    private enum ColourGroup { case neutral, warm, cool, dark }

    private func colourGroup(_ hex: String) -> ColourGroup {
        guard let (r, g, b) = parseHex(hex) else { return .neutral }
        let brightness = (r + g + b) / 3

        if brightness < 0.25                         { return .dark }
        if r > g && r > b && r > 0.55               { return .warm }
        if b > r && b > g && b > 0.45               { return .cool }
        if abs(r - g) < 0.15 && abs(g - b) < 0.15  { return .neutral }
        return .warm
    }

    private func parseHex(_ hex: String) -> (Double, Double, Double)? {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        return (
            Double((val >> 16) & 0xFF) / 255,
            Double((val >>  8) & 0xFF) / 255,
            Double( val        & 0xFF) / 255
        )
    }

    // MARK: - Helpers

    private func bestMatch(for combo: [ClothingItem], from candidates: [ClothingItem]) -> ClothingItem? {
        candidates
            .filter { c in !combo.contains(where: { $0.id == c.id }) }
            .max { colourHarmonyScore(combo + [$0]) < colourHarmonyScore(combo + [$1]) }
    }

    private func inferOccasion(_ items: [ClothingItem]) -> [OccasionTag] {
        let allTags = items.flatMap(\.occasionTags)
        let counts  = Dictionary(allTags.map { ($0, 1) }, uniquingKeysWith: +)
        let sorted  = counts.sorted { $0.value > $1.value }.prefix(2).map(\.key)
        return sorted.isEmpty ? [.casual] : sorted
    }

    private func suggestTitle(_ items: [ClothingItem], occasion: OccasionTag?) -> String {
        let occ = occasion?.rawValue ?? "Casual"
        let prefixes = ["\(occ) Edit", "The \(occ) Look", "\(occ) Ensemble", "Curated \(occ)"]
        let index = abs(items.map { $0.id.hashValue }.reduce(0, +)) % prefixes.count
        return prefixes[index]
    }

    // MARK: - Style Score for saving
    func styleScore(for items: [ClothingItem]) -> Int { computeMatchScore(items) }
    func palette(for items: [ClothingItem]) -> [String] { items.map(\.colorHex) }
}
