import Foundation
import SwiftData

@Model
final class ClothingItem {
    var id: UUID
    var sourceURL: String
    var imageURL: String?
    var imageData: Data?
    var productName: String
    var brand: String
    var category: ClothingCategory
    var occasionTagsRaw: [String]   // stored as [String] for SwiftData compatibility
    var colorHex: String            // dominant colour extracted from image
    var addedAt: Date

    // Transform state for try-on canvas
    var positionX: Double
    var positionY: Double
    var scale: Double
    var rotation: Double

    var occasionTags: [OccasionTag] {
        get { occasionTagsRaw.compactMap { OccasionTag(rawValue: $0) } }
        set { occasionTagsRaw = newValue.map(\.rawValue) }
    }

    init(
        id: UUID = UUID(),
        sourceURL: String,
        imageURL: String? = nil,
        imageData: Data? = nil,
        productName: String = "",
        brand: String = "",
        category: ClothingCategory = .top,
        occasionTags: [OccasionTag] = [.casual],
        colorHex: String = "#C4A882",
        addedAt: Date = .now,
        positionX: Double = 0.5,
        positionY: Double = 0.3,
        scale: Double = 1.0,
        rotation: Double = 0.0
    ) {
        self.id              = id
        self.sourceURL       = sourceURL
        self.imageURL        = imageURL
        self.imageData       = imageData
        self.productName     = productName
        self.brand           = brand
        self.category        = category
        self.occasionTagsRaw = occasionTags.map(\.rawValue)
        self.colorHex        = colorHex
        self.addedAt         = addedAt
        self.positionX       = positionX
        self.positionY       = positionY
        self.scale           = scale
        self.rotation        = rotation
    }
}

enum ClothingCategory: String, Codable, CaseIterable {
    case top       = "Top"
    case bottom    = "Bottom"
    case shoes     = "Shoes"
    case outerwear = "Outerwear"
    case accessory = "Accessory"
    case dress     = "Dress"

    var icon: String {
        switch self {
        case .top:       return "tshirt"
        case .bottom:    return "rectangle.bottomthird.inset.filled"
        case .shoes:     return "shoe"
        case .outerwear: return "wind"
        case .accessory: return "bag"
        case .dress:     return "person.fill"
        }
    }
}
