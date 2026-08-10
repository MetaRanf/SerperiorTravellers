import XCTest

final class AppLaunchTests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        // App should launch and show Explore or first tab content
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
}
