import Foundation

@MainActor
public final class TripsViewModel: ObservableObject {
    @Published public var trips: [Trip] = []
    @Published public var filter: TripStatus? = nil
    @Published public var isLoading = false
    private var storage: StorageServiceProtocol?

    public init() { trips = MockDataProvider.trips }

    public func configure(storage: StorageServiceProtocol) {
        self.storage = storage
        Task { await load() }
    }

    public func load() async {
        isLoading = true
        if let storage { trips = (try? await storage.loadTrips()) ?? MockDataProvider.trips }
        isLoading = false
    }

    public var filteredTrips: [Trip] {
        guard let filter else { return trips.sorted { $0.startDate > $1.startDate } }
        return trips.filter { $0.status == filter }.sorted { $0.startDate > $1.startDate }
    }

    public func deleteTrip(id: UUID) {
        trips.removeAll { $0.id == id }
        Task { try? await storage?.deleteTrip(id: id) }
    }
}
