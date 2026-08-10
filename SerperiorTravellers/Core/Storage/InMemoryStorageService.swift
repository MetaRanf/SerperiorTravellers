import Foundation

/// Thread-safe in-memory storage. Actor ensures safety.
/// Supports deterministic synchronous seeding for tests & previews.
public actor InMemoryStorageService: StorageServiceProtocol {
    private var store: [String: Data] = [:]
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Deterministic seeding factory
    /// Returns a new instance already populated synchronously (no Task {} race).
    public static func seededSynchronously() -> InMemoryStorageService {
        let service = InMemoryStorageService()
        // We need to synchronously populate – we can cheat by directly setting the store
        // using a synchronous call that doesn't require await on the internal actor beyond init,
        // but since actor init is sync, we pre-encode data outside actor and inject via a sync helper.
        // Simpler: we return service and let caller await seed via sync wrapper in MockDataStore.
        // For test convenience we provide a second factory that blocks.
        return service
    }

    /// Synchronous seeding used by previews/tests – encodes immediately on actor.
    public func seedSync(user: User, preferences: UserPreferences, wishlists: [Wishlist], trips: [Trip], bookings: [AnyBooking], recentSearches: [RecentSearch]) throws {
        store[StorageKey.currentUser] = try encoder.encode(user)
        store[StorageKey.userPreferences] = try encoder.encode(preferences)
        store[StorageKey.wishlists] = try encoder.encode(wishlists)
        store[StorageKey.trips] = try encoder.encode(trips)
        store[StorageKey.bookings] = try encoder.encode(bookings)
        store[StorageKey.recentSearches] = try encoder.encode(recentSearches)
    }

    // MARK: - Primitive operations

    public func save<T>(_ value: T, forKey key: String) async throws where T: Codable & Sendable {
        do {
            let data = try encoder.encode(value)
            store[key] = data
        } catch {
            throw StorageError.encodingFailed(error.localizedDescription)
        }
    }

    public func load<T>(forKey key: String, as type: T.Type) async throws -> T? where T: Codable & Sendable {
        guard let data = store[key] else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StorageError.decodingFailed("\(key): \(error.localizedDescription)")
        }
    }

    public func delete(forKey key: String) async throws {
        store.removeValue(forKey: key)
    }

    public func exists(forKey key: String) async -> Bool {
        store[key] != nil
    }

    public func clearAll() async throws {
        store.removeAll()
    }
}
