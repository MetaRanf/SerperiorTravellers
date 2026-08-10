import Foundation

// MARK: - Storage Error

public enum StorageError: LocalizedError, Equatable {
    case notFound(key: String)
    case encodingFailed(String)
    case decodingFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
    case invalidData

    public var errorDescription: String? {
        switch self {
        case .notFound(let key): return "No value found for key: \(key)"
        case .encodingFailed(let m): return "Encoding failed: \(m)"
        case .decodingFailed(let m): return "Decoding failed: \(m)"
        case .saveFailed(let m): return "Save failed: \(m)"
        case .deleteFailed(let m): return "Delete failed: \(m)"
        case .invalidData: return "Invalid data"
        }
    }
}

// MARK: - Storage Keys

public enum StorageKey {
    public static let currentUser = "com.serperior.storage.currentUser"
    public static let userPreferences = "com.serperior.storage.userPreferences"
    public static let wishlists = "com.serperior.storage.wishlists"
    public static let trips = "com.serperior.storage.trips"
    public static let bookings = "com.serperior.storage.bookings"
    public static let trackedPrices = "com.serperior.storage.trackedPrices"
    public static let recentSearches = "com.serperior.storage.recentSearches"
    public static let onboardingCompleted = "com.serperior.storage.onboardingCompleted"
}

// MARK: - Protocol

public protocol StorageServiceProtocol: Sendable {
    func save<T: Codable & Sendable>(_ value: T, forKey key: String) async throws
    func load<T: Codable & Sendable>(forKey key: String, as type: T.Type) async throws -> T?
    func delete(forKey key: String) async throws
    func exists(forKey key: String) async -> Bool
    func clearAll() async throws

    // Domain helpers
    func saveUser(_ user: User) async throws
    func loadUser() async throws -> User?
    func deleteUser() async throws

    func savePreferences(_ preferences: UserPreferences) async throws
    func loadPreferences() async throws -> UserPreferences?

    func saveWishlist(_ wishlist: Wishlist) async throws
    func loadWishlists() async throws -> [Wishlist]
    func loadWishlist(id: UUID) async throws -> Wishlist?
    func deleteWishlist(id: UUID) async throws
    func addItemToWishlist(wishlistID: UUID, item: WishlistItem) async throws
    func removeItemFromWishlist(wishlistID: UUID, itemID: UUID) async throws

    func saveTrip(_ trip: Trip) async throws
    func loadTrips() async throws -> [Trip]
    func loadTrip(id: UUID) async throws -> Trip?
    func deleteTrip(id: UUID) async throws

    func saveBooking(_ booking: AnyBooking) async throws
    func loadBookings() async throws -> [AnyBooking]
    func loadBooking(id: UUID) async throws -> AnyBooking?

    func saveRecentSearch(_ search: RecentSearch) async throws
    func loadRecentSearches() async throws -> [RecentSearch]
    func clearRecentSearches() async throws

    func saveTrackedPrice(_ item: TrackedPriceItem) async throws
    func loadTrackedPrices() async throws -> [TrackedPriceItem]
    func deleteTrackedPrice(id: UUID) async throws
}

// MARK: - Default implementations over 5 primitives

public extension StorageServiceProtocol {
    func saveUser(_ user: User) async throws { try await save(user, forKey: StorageKey.currentUser) }
    func loadUser() async throws -> User? { try await load(forKey: StorageKey.currentUser, as: User.self) }
    func deleteUser() async throws { try await delete(forKey: StorageKey.currentUser) }

    func savePreferences(_ preferences: UserPreferences) async throws {
        try await save(preferences, forKey: StorageKey.userPreferences)
    }
    func loadPreferences() async throws -> UserPreferences? {
        try await load(forKey: StorageKey.userPreferences, as: UserPreferences.self)
    }

    func saveWishlist(_ wishlist: Wishlist) async throws {
        var all = try await loadWishlists()
        if let idx = all.firstIndex(where: { $0.id == wishlist.id }) {
            all[idx] = wishlist
        } else {
            all.append(wishlist)
        }
        try await save(all, forKey: StorageKey.wishlists)
    }
    func loadWishlists() async throws -> [Wishlist] {
        (try await load(forKey: StorageKey.wishlists, as: [Wishlist].self)) ?? []
    }
    func loadWishlist(id: UUID) async throws -> Wishlist? {
        try await loadWishlists().first(where: { $0.id == id })
    }
    func deleteWishlist(id: UUID) async throws {
        var all = try await loadWishlists()
        all.removeAll { $0.id == id }
        try await save(all, forKey: StorageKey.wishlists)
    }
    func addItemToWishlist(wishlistID: UUID, item: WishlistItem) async throws {
        var all = try await loadWishlists()
        guard let idx = all.firstIndex(where: { $0.id == wishlistID }) else {
            throw StorageError.notFound(key: wishlistID.uuidString)
        }
        if !all[idx].items.contains(where: { $0.id == item.id }) {
            all[idx].items.append(item)
            all[idx].updatedAt = Date()
            try await save(all, forKey: StorageKey.wishlists)
        }
    }
    func removeItemFromWishlist(wishlistID: UUID, itemID: UUID) async throws {
        var all = try await loadWishlists()
        guard let idx = all.firstIndex(where: { $0.id == wishlistID }) else {
            throw StorageError.notFound(key: wishlistID.uuidString)
        }
        all[idx].items.removeAll { $0.id == itemID }
        all[idx].updatedAt = Date()
        try await save(all, forKey: StorageKey.wishlists)
    }

    func saveTrip(_ trip: Trip) async throws {
        var all = try await loadTrips()
        if let idx = all.firstIndex(where: { $0.id == trip.id }) {
            all[idx] = trip
        } else {
            all.append(trip)
        }
        try await save(all, forKey: StorageKey.trips)
    }
    func loadTrips() async throws -> [Trip] {
        (try await load(forKey: StorageKey.trips, as: [Trip].self)) ?? []
    }
    func loadTrip(id: UUID) async throws -> Trip? {
        try await loadTrips().first(where: { $0.id == id })
    }
    func deleteTrip(id: UUID) async throws {
        var all = try await loadTrips()
        all.removeAll { $0.id == id }
        try await save(all, forKey: StorageKey.trips)
    }

    func saveBooking(_ booking: AnyBooking) async throws {
        var all = try await loadBookings()
        if let idx = all.firstIndex(where: { $0.id == booking.id }) {
            all[idx] = booking
        } else {
            all.append(booking)
        }
        try await save(all, forKey: StorageKey.bookings)
    }
    func loadBookings() async throws -> [AnyBooking] {
        (try await load(forKey: StorageKey.bookings, as: [AnyBooking].self)) ?? []
    }
    func loadBooking(id: UUID) async throws -> AnyBooking? {
        try await loadBookings().first(where: { $0.id == id })
    }

    func saveRecentSearch(_ search: RecentSearch) async throws {
        var all = try await loadRecentSearches()
        all.removeAll { $0.query.lowercased() == search.query.lowercased() }
        all.insert(search, at: 0)
        if all.count > 20 { all = Array(all.prefix(20)) }
        try await save(all, forKey: StorageKey.recentSearches)
    }
    func loadRecentSearches() async throws -> [RecentSearch] {
        (try await load(forKey: StorageKey.recentSearches, as: [RecentSearch].self)) ?? []
    }
    func clearRecentSearches() async throws {
        try await delete(forKey: StorageKey.recentSearches)
    }

    func saveTrackedPrice(_ item: TrackedPriceItem) async throws {
        var all = try await loadTrackedPrices()
        if let idx = all.firstIndex(where: { $0.id == item.id }) {
            all[idx] = item
        } else {
            all.append(item)
        }
        try await save(all, forKey: StorageKey.trackedPrices)
    }
    func loadTrackedPrices() async throws -> [TrackedPriceItem] {
        (try await load(forKey: StorageKey.trackedPrices, as: [TrackedPriceItem].self)) ?? []
    }
    func deleteTrackedPrice(id: UUID) async throws {
        var all = try await loadTrackedPrices()
        all.removeAll { $0.id == id }
        try await save(all, forKey: StorageKey.trackedPrices)
    }
}
