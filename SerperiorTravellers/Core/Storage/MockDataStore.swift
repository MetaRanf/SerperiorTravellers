import Foundation

/// Deterministic seeder – no fire-and-forget Task {}.
/// Caller must `await` this before first use.
public enum MockDataStore {
    public static func seed(to storage: StorageServiceProtocol) async throws {
        // If the concrete type is InMemoryStorageService we can use the sync fast path
        // to guarantee immediate availability, but we still await for protocol uniformity.
        if let mem = storage as? InMemoryStorageService {
            try await mem.seedSync(
                user: MockDataProvider.currentUser,
                preferences: MockDataProvider.currentUser.preferences,
                wishlists: MockDataProvider.wishlists,
                trips: MockDataProvider.trips,
                bookings: MockDataProvider.sampleBookings,
                recentSearches: [
                    RecentSearch(query: "Kyoto", type: .destination),
                    RecentSearch(query: "Bali villas", type: .hotel),
                    RecentSearch(query: "Santorini sunset tour", type: .activity)
                ]
            )
            return
        }

        // Generic path for any StorageServiceProtocol
        try await storage.saveUser(MockDataProvider.currentUser)
        try await storage.savePreferences(MockDataProvider.currentUser.preferences)
        for wl in MockDataProvider.wishlists {
            try await storage.saveWishlist(wl)
        }
        for trip in MockDataProvider.trips {
            try await storage.saveTrip(trip)
        }
        for booking in MockDataProvider.sampleBookings {
            try await storage.saveBooking(booking)
        }
        let searches = [
            RecentSearch(query: "Kyoto", type: .destination),
            RecentSearch(query: "Bali villas", type: .hotel),
            RecentSearch(query: "Santorini sunset tour", type: .activity)
        ]
        for s in searches {
            try await storage.saveRecentSearch(s)
        }
    }

    /// Synchronous creation for previews that need immediate data.
    /// Uses the actor's seedSync under the hood but blocks via detaching? Instead we directly
    /// encode here using same JSON logic and return a service that is already seeded.
    @MainActor
    public static func makeSeededMemoryStorageSync() -> InMemoryStorageService {
        let service = InMemoryStorageService()
        // We can't call actor method from sync non-isolated, but we are on MainActor,
        // and seedSync is actor-isolated – we need to use unsafe trick:
        // Since we control encoding, we create a blocking Task and wait (for preview only).
        // For unit tests, use async seed(to:).
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            try? await service.seedSync(
                user: MockDataProvider.currentUser,
                preferences: MockDataProvider.currentUser.preferences,
                wishlists: MockDataProvider.wishlists,
                trips: MockDataProvider.trips,
                bookings: MockDataProvider.sampleBookings,
                recentSearches: [
                    RecentSearch(query: "Kyoto"),
                    RecentSearch(query: "Bali"),
                    RecentSearch(query: "Santorini")
                ]
            )
            semaphore.signal()
        }
        semaphore.wait()
        return service
    }
}
