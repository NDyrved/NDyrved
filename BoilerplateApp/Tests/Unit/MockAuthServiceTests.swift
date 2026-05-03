import XCTest
@testable import BoilerplateApp

final class MockAuthServiceTests: XCTestCase {
    func testLoginSucceeds() async throws {
        let store = SessionStore(defaults: UserDefaults(suiteName: #file)!)
        let service = MockAuthService(sessionStore: store)
        let user = try await service.login(email: "test@example.com", password: "123456")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertTrue(store.isAuthenticated)
    }
}
