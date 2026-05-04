import Foundation
import UIKit

/// Transient (in-memory) model used during an active try-on session.
/// Not persisted via SwiftData — converted to Outfit on save.
struct TryOnSession: Identifiable {
    var id: UUID = UUID()
    var bodyPhoto: UIImage?
    var items: [ClothingItem] = []
    var activeItemID: UUID?

    var isEmpty: Bool { bodyPhoto == nil && items.isEmpty }
}
