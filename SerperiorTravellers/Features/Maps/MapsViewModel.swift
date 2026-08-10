import Foundation

@MainActor
public final class MapsViewModel: ObservableObject {
    @Published public var pins: [MapPin] = []
    @Published public var route: SuggestedRoute? = nil
    @Published public var selectedDestinationId: UUID? = MockDataProvider.destinations.first?.id
    @Published public var isLoading = false

    private var mapsService: MapsServiceProtocol?

    public init() {}

    public func configure(service: MapsServiceProtocol) {
        self.mapsService = service
        Task { await loadPins() }
    }

    public func loadPins() async {
        guard let mapsService, let destId = selectedDestinationId else { return }
        isLoading = true
        if let pins = try? await mapsService.getPins(for: destId) {
            self.pins = pins
        }
        if let trip = MockDataProvider.trips.first {
            route = try? await mapsService.suggestedRoute(for: trip)
        }
        isLoading = false
    }

    public func loadTripPins(tripId: UUID) async {
        guard let mapsService else { return }
        pins = (try? await mapsService.getPins(forTrip: tripId)) ?? []
        if let trip = MockDataProvider.trips.first(where: { $0.id == tripId }) {
            route = try? await mapsService.suggestedRoute(for: trip)
        }
    }
}
