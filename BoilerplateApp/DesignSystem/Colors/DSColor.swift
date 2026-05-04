import SwiftUI

/// Central colour palette — warm editorial neutrals with espresso accent.
/// All colours are adaptive (light + dark mode) via inline UIColor initialisers,
/// so no asset catalogue entries are required.
enum DSColor {
    // MARK: - Backgrounds
    static let background = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.09, blue: 0.09, alpha: 1)  // near-black
            : UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1)  // warm cream
    })
    static let card = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.15, blue: 0.13, alpha: 1)  // dark charcoal
            : UIColor(red: 1.00, green: 0.99, blue: 0.97, alpha: 1)  // off-white
    })
    static let surface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.22, green: 0.20, blue: 0.18, alpha: 1)
            : UIColor(red: 0.94, green: 0.92, blue: 0.89, alpha: 1)  // linen
    })

    // MARK: - Accent (espresso brown)
    static let accent = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.80, green: 0.58, blue: 0.38, alpha: 1)  // warm caramel
            : UIColor(red: 0.52, green: 0.28, blue: 0.10, alpha: 1)  // espresso
    })
    static var accentMuted: Color { accent.opacity(0.12) }

    // MARK: - Text
    static let textPrimary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.95, green: 0.94, blue: 0.92, alpha: 1)
            : UIColor(red: 0.11, green: 0.09, blue: 0.08, alpha: 1)
    })
    static let textSecondary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.62, green: 0.60, blue: 0.57, alpha: 1)
            : UIColor(red: 0.42, green: 0.38, blue: 0.34, alpha: 1)
    })
    static let textTertiary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.42, green: 0.40, blue: 0.38, alpha: 1)
            : UIColor(red: 0.62, green: 0.58, blue: 0.54, alpha: 1)
    })

    // MARK: - Borders
    static let border = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.26, green: 0.24, blue: 0.22, alpha: 1)
            : UIColor(red: 0.87, green: 0.84, blue: 0.80, alpha: 1)
    })

    // MARK: - Semantic
    static let success     = Color(red: 0.20, green: 0.65, blue: 0.40)
    static let destructive = Color(red: 0.85, green: 0.25, blue: 0.20)
}
