import Foundation
import SwiftData

@Model
final class Outfit {
    var id: UUID
    var name: String
    var bodyPhotoData: Data?
    var createdAt: Date
    var updatedAt: Date
    var isFavourite: Bool
    var styleScore: Int             // 0–100, computed on save
    var tagRaws: [String]           // [OccasionTag.rawValue]
    var colorPalette: [String]      // hex strings extracted from items

    @Relationship(deleteRule: .cascade)
    var items: [ClothingItem]

    var tags: [OccasionTag] {
        get { tagRaws.compactMap { OccasionTag(rawValue: $0) } }
        set { tagRaws = newValue.map(\.rawValue) }
    }

    init(
        id: UUID = UUID(),
        name: String = "My Outfit",
        bodyPhotoData: Data? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isFavourite: Bool = false,
        styleScore: Int = 0,
        tags: [OccasionTag] = [.casual],
        colorPalette: [String] = [],
        items: [ClothingItem] = []
    ) {
        self.id            = id
        self.name          = name
        self.bodyPhotoData = bodyPhotoData
        self.createdAt     = createdAt
        self.updatedAt     = updatedAt
        self.isFavourite   = isFavourite
        self.styleScore    = styleScore
        self.tagRaws       = tags.map(\.rawValue)
        self.colorPalette  = colorPalette
        self.items         = items
    }
}
