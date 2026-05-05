import Foundation

/// Wraps any product URL with Sovrn Commerce affiliate tracking.
/// All outbound "buy" links in the app pass through this — zero extra setup per brand.
struct AffiliateService {

    private static let sovrnKey = "f57bc2f0eee75830d3e641df50576af4"

    /// Returns a Sovrn-tracked URL for any product link.
    /// Falls back to the original URL if encoding fails.
    static func affiliateURL(for rawURL: String) -> URL? {
        guard
            let encoded = rawURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let tracked = URL(string: "https://redirect.viglink.com?key=\(sovrnKey)&u=\(encoded)")
        else {
            return URL(string: rawURL)
        }
        return tracked
    }
}
