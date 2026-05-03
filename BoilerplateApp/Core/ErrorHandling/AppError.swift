import Foundation

enum AppError: Error, LocalizedError {
    case invalidCredentials
    case networkUnavailable
    case generic(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password."
        case .networkUnavailable: return "Network is unavailable."
        case let .generic(message): return message
        }
    }
}
