import Foundation
import CoreLocation
import MapKit

public enum MapsServiceError: LocalizedError {
    case geocodingFailed(String)
    case routingFailed(String)
    case locationUnavailable
    case notFound
    public var errorDescription: String? {
        switch self {
        case .geocodingFailed(let m): return "Geocoding failed: \(m)"
        case .routingFailed(let m): return "Routing failed: \(m)"
        case .locationUnavailable: return "User location unavailable"
        case .notFound: return "Place not found"
        }
    }
}

public struct MapPin: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var coordinate: GeoCoordinate
    public var title: String
    public var subtitle: String?
    public var type: PinType
    public enum PinType: String, Codable, Sendable { case destination, property, activity, user, hotel, flight }
    public init(id: UUID = UUID(), coordinate: GeoCoordinate, title: String, subtitle: String? = nil, type: PinType) {
        self.id = id; self.coordinate = coordinate; self.title = title; self.subtitle = subtitle; self.type = type
    }
}

public struct SuggestedRoute: Equatable, Sendable {
    public var pins: [MapPin]
    public var polyline: [GeoCoordinate]
    public var totalDistanceMeters: Double
    public var estimatedDurationMinutes: Int

    public var formattedDistance: String {
        if totalDistanceMeters < 1000 { return "\(Int(totalDistanceMeters)) m" }
        return String(format: "%.1f km", totalDistanceMeters/1000)
    }

    public init(pins: [MapPin], polyline: [GeoCoordinate], totalDistanceMeters: Double, estimatedDurationMinutes: Int) {
        self.pins = pins; self.polyline = polyline; self.totalDistanceMeters = totalDistanceMeters; self.estimatedDurationMinutes = estimatedDurationMinutes
    }
}

public protocol MapsServiceProtocol: Sendable {
    func geocode(address: String) async throws -> GeoCoordinate
    func reverseGeocode(coordinate: GeoCoordinate) async throws -> String
    func getPins(for destinationId: UUID) async throws -> [MapPin]
    func getPins(forTrip tripId: UUID) async throws -> [MapPin]
    func calculateRoute(from: GeoCoordinate, to: GeoCoordinate) async throws -> SuggestedRoute
    func suggestedRoute(for trip: Trip) async throws -> SuggestedRoute
    func searchNearby(coordinate: GeoCoordinate, radiusMeters: Double, query: String?) async throws -> [MapPin]
}
