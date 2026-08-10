import XCTest
@testable import SerperiorTravellers

final class StorageServiceTests: XCTestCase {
    var storage: InMemoryStorageService!

    override func setUp() async throws {
        storage = InMemoryStorageService()
    }

    func testSaveLoadRoundTrip() async throws {
        let user = User.preview
        try await storage.saveUser(user)
        let loaded = try await storage.loadUser()
        XCTAssertEqual(loaded?.id, user.id)
    }

    func testLoadMissingReturnsNil() async throws {
        let loaded = try await storage.loadUser()
        XCTAssertNil(loaded)
    }

    func testDeleteRemoves() async throws {
        let user = User.preview
        try await storage.saveUser(user)
        let exists1 = await storage.exists(forKey: StorageKey.currentUser)
        XCTAssertTrue(exists1)
        try await storage.delete(forKey: StorageKey.currentUser)
        let exists2 = await storage.exists(forKey: StorageKey.currentUser)
        XCTAssertFalse(exists2)
    }

    func testWishlistCRUD() async throws {
        let wl = Wishlist(userId: UUID(), title: "Test WL", type: .location)
        try await storage.saveWishlist(wl)
        var all = try await storage.loadWishlists()
        XCTAssertEqual(all.count, 1)

        let item = WishlistItem.destinationItem(destinationId: UUID())
        try await storage.addItemToWishlist(wishlistID: wl.id, item: item)
        all = try await storage.loadWishlists()
        XCTAssertEqual(all.first?.itemCount, 1)

        try await storage.removeItemFromWishlist(wishlistID: wl.id, itemID: item.id)
        all = try await storage.loadWishlists()
        XCTAssertEqual(all.first?.itemCount, 0)

        try await storage.deleteWishlist(id: wl.id)
        all = try await storage.loadWishlists()
        XCTAssertTrue(all.isEmpty)
    }

    func testSeededStorageReturnsDataImmediately() async throws {
        try await MockDataStore.seed(to: storage)
        let wishlists = try await storage.loadWishlists()
        let trips = try await storage.loadTrips()
        XCTAssertFalse(wishlists.isEmpty, "Seeded wishlists should not be empty")
        XCTAssertFalse(trips.isEmpty, "Seeded trips should not be empty")
        let recents = try await storage.loadRecentSearches()
        XCTAssertFalse(recents.isEmpty)
    }

    func testRecentSearchDeduplication() async throws {
        let s1 = RecentSearch(query: "Kyoto", type: .destination)
        let s2 = RecentSearch(query: "kyoto", type: .destination)
        try await storage.saveRecentSearch(s1)
        try await storage.saveRecentSearch(s2)
        let all = try await storage.loadRecentSearches()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.query, "kyoto")
    }
}
