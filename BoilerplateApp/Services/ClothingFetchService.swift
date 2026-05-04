import Foundation
import UIKit

struct FetchedClothingMeta {
    let productName: String
    let imageURL: URL?
    let imageData: Data?
}

/// Fetches clothing product metadata from a pasted URL by parsing OpenGraph / meta tags.
final class ClothingFetchService {

    enum FetchError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case noImageFound
        case imageDownloadFailed

        var errorDescription: String? {
            switch self {
            case .invalidURL:          return "The URL you entered isn't valid."
            case .networkError(let e): return "Network error: \(e.localizedDescription)"
            case .noImageFound:        return "No product image found at that URL."
            case .imageDownloadFailed: return "Couldn't download the product image."
            }
        }
    }

    func fetch(urlString: String) async throws -> FetchedClothingMeta {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw FetchError.invalidURL
        }

        // Download the HTML
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")

        let (data, _): (Data, URLResponse)
        do {
            (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            throw FetchError.networkError(error)
        }

        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw FetchError.noImageFound
        }

        let meta = parseOpenGraph(html: html, baseURL: url)

        // Download the product image
        if let imageURL = meta.imageURL {
            do {
                let (imgData, _) = try await URLSession.shared.data(from: imageURL)
                return FetchedClothingMeta(productName: meta.title, imageURL: imageURL, imageData: imgData)
            } catch {
                throw FetchError.imageDownloadFailed
            }
        }

        throw FetchError.noImageFound
    }

    // MARK: - HTML Parsing

    private struct ParsedMeta {
        var title: String
        var imageURL: URL?
    }

    private func parseOpenGraph(html: String, baseURL: URL) -> ParsedMeta {
        var title = ""
        var imageURLString: String?

        // og:image
        if let match = html.range(of: #"og:image["\s][^>]*content=["']([^"']+)["']"#,
                                   options: .regularExpression) {
            let sub = String(html[match])
            imageURLString = extractContent(from: sub)
        }

        // Fallback: content before property for some tag orders
        if imageURLString == nil,
           let match = html.range(of: #"content=["']([^"']+)["'][^>]*og:image"#,
                                   options: .regularExpression) {
            let sub = String(html[match])
            imageURLString = extractFirstQuotedValue(from: sub)
        }

        // og:title
        if let match = html.range(of: #"og:title["\s][^>]*content=["']([^"']+)["']"#,
                                   options: .regularExpression) {
            title = extractContent(from: String(html[match])) ?? ""
        }

        // Fallback <title>
        if title.isEmpty,
           let match = html.range(of: #"<title[^>]*>([^<]+)</title>"#,
                                   options: .regularExpression) {
            title = String(html[match])
                .replacingOccurrences(of: #"<title[^>]*>"#, with: "", options: .regularExpression)
                .replacingOccurrences(of: "</title>", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var imageURL: URL?
        if let str = imageURLString {
            imageURL = URL(string: str) ?? URL(string: str, relativeTo: baseURL)
        }

        return ParsedMeta(title: title, imageURL: imageURL)
    }

    private func extractContent(from tag: String) -> String? {
        guard let range = tag.range(of: #"content=["']([^"']+)["']"#, options: .regularExpression) else { return nil }
        let sub = String(tag[range])
        return extractFirstQuotedValue(from: sub)
    }

    private func extractFirstQuotedValue(from string: String) -> String? {
        let pattern = #"["']([^"']+)["']"#
        guard let range = string.range(of: pattern, options: .regularExpression) else { return nil }
        var result = String(string[range])
        result.removeFirst()
        result.removeLast()
        return result.isEmpty ? nil : result
    }
}
