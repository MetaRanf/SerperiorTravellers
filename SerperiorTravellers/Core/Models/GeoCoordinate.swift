import Foundation
import CoreLocation

// MARK: - GeoCoordinate
/// Codable-safe coordinate. Bridges to CLLocationCoordinate2D / MapKit.
public struct GeoCoordinate: Codable, Equatable, Sendable, Hashable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    public var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    public func distance(to other: GeoCoordinate) -> CLLocationDistance {
        clLocation.distance(from: other.clLocation)
    }

    private enum CodingKeys: String, CodingKey {
        case latitude, longitude, lat, lng
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let lat = try? container.decode(Double.self, forKey: .latitude),
           let lng = try? container.decode(Double.self, forKey: .longitude) {
            latitude = lat
            longitude = lng
        } else {
            latitude = try container.decode(Double.self, forKey: .lat)
            longitude = try container.decode(Double.self, forKey: .lng)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
