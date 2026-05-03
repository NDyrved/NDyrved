import Foundation

protocol SecureStoring {
    func set(_ value: Data, for key: String) throws
    func get(for key: String) throws -> Data?
}

struct KeychainStore: SecureStoring {
    func set(_ value: Data, for key: String) throws {
        // TODO: Replace with Security framework-backed implementation.
    }

    func get(for key: String) throws -> Data? {
        // TODO: Replace with Security framework-backed implementation.
        nil
    }
}
