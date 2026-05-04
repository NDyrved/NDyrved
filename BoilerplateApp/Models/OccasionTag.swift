import Foundation

enum OccasionTag: String, Codable, CaseIterable, Identifiable {
    case casual      = "Casual"
    case smartCasual = "Smart Casual"
    case formal      = "Formal"
    case weekend     = "Weekend"
    case work        = "Work"
    case sport       = "Sport"
    case evening     = "Evening"

    var id: String { rawValue }
}
