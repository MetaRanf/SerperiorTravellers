import Foundation

public actor MockMapsService: MapsServiceProtocol {
    public var latency: Duration = .zero

    public init(latency: Duration = .zero) {
        self.latency = latency
    }

    private func simulateLatencyIfNeeded() async {
        guard latency > .zero else { return }
        try? await Task.sleep(for: latency)
    }

    public func geocode(address: String) async throws -> GeoCoordinate {
        await simulateLatencyIfNeeded()
        // Return first destination coordinate for mock
        if let dest = MockDataProvider.destinations.first(where: { $0.name.localizedCaseInsensitiveContains(address) }) {
            return dest.coordinates
        }
        return GeoCoordinate(latitude: 37.7749, longitude: -122.4194)
    }

    public func reverseGeocode(coordinate: GeoCoordinate) async throws -> String {
        await simulateLatencyIfNeeded()
        return "Near \(coordinate.latitude), \(coordinate.longitude)"
    }

    public func getPins(for destinationId: UUID) async throws -> [MapPin] {
        await simulateLatencyIfNeeded()
        guard let dest = MockDataProvider.destinations.first(where: { $0.id == destinationId }) else { return [] }
        var pins: [MapPin] = [
            MapPin(coordinate: dest.coordinates, title: dest.name, subtitle: dest.country, type: .destination)
        ]
        let props = MockDataProvider.properties.filter { $0.destinationId == destinationId }
        pins.append(contentsOf: props.map { MapPin(coordinate: $0.coordinates, title: $0.title, subtitle: $0.type.displayName, type: .property) })
        let acts = MockDataProvider.activities.filter { $0.destinationId == destinationId }
        pins.append(contentsOf: acts.compactMap { act in
            guard let coord = act.coordinates else { return nil }
            return MapPin(coordinate: coord, title: act.title, subtitle: act.category.displayName, type: .activity)
        })
        return pins
    }

    public func getPins(forTrip tripId: UUID) async throws -> [MapPin] {
        await simulateLatencyIfNeeded()
        guard let trip = MockDataProvider.trips.first(where: { $0.id == tripId }) else { return [] }
        var pins: [MapPin] = []
        for destId in trip.destinationIds {
            if let dest = MockDataProvider.destinations.first(where: { $0.id == destId }) {
                pins.append(MapPin(coordinate: dest.coordinates, title: dest.name, subtitle: "Trip stop", type: .destination))
            }
        }
        for day in trip.days {
            for ta in day.activities {
                if let act = MockDataProvider.activities.first(where: { $0.id == ta.activityId }),
                   let coord = act.coordinates {
                    pins.append(MapPin(coordinate: coord, title: act.title, type: .activity))
                }
            }
        }
        return pins
    }

    public func calculateRoute(from: GeoCoordinate, to: GeoCoordinate) async throws -> SuggestedRoute {
        await simulateLatencyIfNeeded()
        let pins = [
            MapPin(coordinate: from, title: "Start", type: .user),
            MapPin(coordinate: to, title: "End", type: .destination)
        ]
        let distance = from.distance(to: to)
        let polyline = [from, to]
        return SuggestedRoute(pins: pins, polyline: polyline, totalDistanceMeters: distance, estimatedDurationMinutes: Int(distance / 800)) // ~48km/h
    }

    public func suggestedRoute(for trip: Trip) async throws -> SuggestedRoute {
        await simulateLatencyIfNeeded()
        let pins = try await getPins(forTrip: trip.id)
        guard pins.count >= 2 else {
            return SuggestedRoute(pins: pins, polyline: pins.map(\.coordinate), totalDistanceMeters: 0, estimatedDurationMinutes: 0)
        }
        let coords = pins.map(\.coordinate)
        var total: Double = 0
        for i in 0..<coords.count-1 {
            total += coords[i].distance(to: coords[i+1])
        }
        return SuggestedRoute(pins: pins, polyline: coords, totalDistanceMeters: total, estimatedDurationMinutes: pins.count * 20)
    }

    public func searchNearby(coordinate: GeoCoordinate, radiusMeters: Double, query: String?) async throws -> [MapPin] {
        await simulateLatencyIfNeeded()
        var all = MockDataProvider.destinations.map { MapPin(coordinate: $0.coordinates, title: $0.name, subtitle: $0.country, type: .destination) }
        if let q = query, !q.isEmpty {
            all = all.filter { $0.title.localizedCaseInsensitiveContains(q) }
        }
        return all.filter { $0.coordinate.distance(to: coordinate) <= radiusMeters }
    }
}
