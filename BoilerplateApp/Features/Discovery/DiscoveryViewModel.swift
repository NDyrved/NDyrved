import Foundation
import UIKit

@MainActor
final class DiscoveryViewModel: ObservableObject {

    enum FetchState {
        case idle
        case loading
        case success(FetchedClothingMeta, String)   // meta + original URL
        case error(String)
    }

    @Published var urlInput: String = ""
    @Published var fetchState: FetchState = .idle
    @Published var savedToWardrobe = false
    @Published var savedToWishlist = false
    @Published var showTryOn = false
    @Published var tryOnItem: ClothingItem? = nil

    private let clothingFetch: ClothingFetchService

    init(clothingFetch: ClothingFetchService = ClothingFetchService()) {
        self.clothingFetch = clothingFetch
    }

    func fetchProduct(outfitStore: OutfitStore) async {
        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        fetchState = .loading
        // Pre-populate toggle state from existing saved items
        savedToWardrobe = outfitStore.isInWardrobe(sourceURL: trimmed)
        savedToWishlist = outfitStore.isInWishlist(sourceURL: trimmed)
        do {
            let meta = try await clothingFetch.fetch(urlString: trimmed)
            fetchState = .success(meta, trimmed)
        } catch {
            fetchState = .error(error.localizedDescription)
        }
    }

    func reset() {
        urlInput = ""
        fetchState = .idle
        savedToWardrobe = false
        savedToWishlist = false
    }

    /// Builds a ClothingItem from the fetched metadata
    func makeClothingItem(from meta: FetchedClothingMeta, url: String) -> ClothingItem {
        ClothingItem(
            sourceURL: url,
            imageURL: meta.imageURL?.absoluteString,
            imageData: meta.imageData,
            productName: meta.productName,
            brand: host(from: url)
        )
    }

    func affiliateURL(for rawURL: String) -> URL? {
        AffiliateService.affiliateURL(for: rawURL)
    }

    private func host(from urlString: String) -> String {
        URL(string: urlString)?.host?
            .replacingOccurrences(of: "www.", with: "")
            .components(separatedBy: ".").first?
            .capitalized ?? ""
    }
}
