import Foundation

@MainActor
final class DiscoveryViewModel: ObservableObject {
    @Published var outfits: [DiscoveryOutfit] = []
    @Published var selectedStore: RetailStore? = nil   // single-brand radio selection
    @Published var selectedOccasion: OccasionTag? = nil
    @Published var sortOption: DiscoverySortOption = .aiScore
    @Published var isLoading = false

    private let service: DiscoveryService

    init(service: DiscoveryService) {
        self.service = service
    }

    func load() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 400_000_000)
        outfits = service.fetchOutfits(store: selectedStore,
                                       occasion: selectedOccasion,
                                       sort: sortOption)
        isLoading = false
    }

    /// Radio-style: tap the same store again to deselect (show all)
    func selectStore(_ store: RetailStore) {
        selectedStore = (selectedStore == store) ? nil : store
        Task { await load() }
    }

    func selectOccasion(_ tag: OccasionTag?) {
        selectedOccasion = tag
        Task { await load() }
    }

    func applySort(_ option: DiscoverySortOption) {
        sortOption = option
        Task { await load() }
    }
}
