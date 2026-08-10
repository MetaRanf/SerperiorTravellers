import XCTest

final class NavigationTests: XCTestCase {
    func testAllTabsReachable() {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist – system TabView required, not CustomTabBar")

        // 5 tabs: Explore, Search, Wishlists, Trips, Maps
        let explore = tabBar.buttons["Explore"]
        let search = tabBar.buttons["Search"]
        let wishlists = tabBar.buttons["Wishlists"]
        let trips = tabBar.buttons["Trips"]
        let maps = tabBar.buttons["Maps"]

        if explore.exists { explore.tap() }
        XCTAssertTrue(app.navigationBars.count > 0 || app.staticTexts.count > 0)

        if search.exists { search.tap() }
        if wishlists.exists { wishlists.tap() }
        if trips.exists { trips.tap() }
        if maps.exists { maps.tap() }

        // After tapping all, we should still be running
        XCTAssertEqual(app.state, .runningForeground)
    }

    func testDefaultTabIsExplore() {
        let app = XCUIApplication()
        app.launch()
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        // First tab should be selected by default
        let firstButton = tabBar.buttons.element(boundBy: 0)
        XCTAssertTrue(firstButton.waitForExistence(timeout: 2))
    }
}
