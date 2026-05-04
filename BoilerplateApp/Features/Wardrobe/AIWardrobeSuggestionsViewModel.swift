import Foundation

@MainActor
final class AIWardrobeSuggestionsViewModel: ObservableObject {
    @Published var suggestions: [OutfitSuggestion] = []
    @Published var selectedOccasion: OccasionTag? = nil
    @Published var isLoading = false

    private let aiService: AIStyleService
    private let store: OutfitStore

    init(aiService: AIStyleService, store: OutfitStore) {
        self.aiService = aiService
        self.store = store
    }

    func generate() async {
        isLoading = true
        let items = store.allClothingItems()
        // Small artificial delay to feel responsive
        try? await Task.sleep(nanoseconds: 600_000_000)
        suggestions = aiService.generateSuggestions(from: items, occasion: selectedOccasion)
        isLoading = false
    }

    func saveToWardrobe(_ suggestion: OutfitSuggestion, store: OutfitStore, aiService: AIStyleService) {
        let outfit = Outfit(
            name: suggestion.title,
            styleScore: suggestion.aiMatchPercent,
            tags: suggestion.occasionTags,
            colorPalette: suggestion.colorPalette,
            items: suggestion.items
        )
        store.saveOutfit(outfit)
    }
}
