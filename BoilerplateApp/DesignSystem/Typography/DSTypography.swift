import SwiftUI

/// Editorial type scale — clean, high-contrast, fashion-forward.
enum DSTypography {
    // MARK: - Display (hero/splash usage)
    static let display = Font.system(size: 48, weight: .black, design: .default)

    // MARK: - Titles
    static let title    = Font.system(size: 28, weight: .bold,     design: .default)
    static let title2   = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3   = Font.system(size: 18, weight: .semibold, design: .default)

    // MARK: - Body
    static let body      = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)

    // MARK: - Supporting
    static let label    = Font.system(size: 14, weight: .medium,  design: .default)
    static let caption  = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .medium,  design: .default)

    // MARK: - Monospaced (prices, scores)
    static let price    = Font.system(size: 16, weight: .semibold, design: .monospaced)
    static let score    = Font.system(size: 22, weight: .black,    design: .monospaced)
}
