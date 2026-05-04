import Foundation

@MainActor
final class DiscoveryViewModel: ObservableObject {
    @Published var outfits: [DiscoveryOutfit] = []
    @Published var selectedStores = Set<RetailStore>()
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
        outfits = service.fetchOutfits(stores: selectedStores,
                                       occasion: selectedOccasion,
                                       sort: sortOption)
        isLoading = false
    }

    func toggleStore(_ store: RetailStore) {
        if selectedStores.contains(store) { selectedStores.remove(store) }
        else { selectedStores.insert(store) }
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
