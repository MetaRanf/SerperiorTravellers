import Foundation

public struct Destination: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var country: String
    public var countryCode: String
    public var description: String
    public var imageURLs: [URL]
    public var coordinates: GeoCoordinate
    public var rating: Double
    public var reviewCount: Int
    public var isTrending: Bool
    public var tags: [String]
    public var activityIds: [UUID]
    public var propertyIds: [UUID]
    public var continent: String?
    public var timezoneIdentifier: String?
    public var bestMonths: [Int]

    public init(
        id: UUID = UUID(),
        name: String,
        country: String,
        countryCode: String = "",
        description: String,
        imageURLs: [URL] = [],
        coordinates: GeoCoordinate,
        rating: Double = 0,
        reviewCount: Int = 0,
        isTrending: Bool = false,
        tags: [String] = [],
        activityIds: [UUID] = [],
        propertyIds: [UUID] = [],
        continent: String? = nil,
        timezoneIdentifier: String? = nil,
        bestMonths: [Int] = []
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.countryCode = countryCode
        self.description = description
        self.imageURLs = imageURLs
        self.coordinates = coordinates
        self.rating = rating
        self.reviewCount = reviewCount
        self.isTrending = isTrending
        self.tags = tags
        self.activityIds = activityIds
        self.propertyIds = propertyIds
        self.continent = continent
        self.timezoneIdentifier = timezoneIdentifier
        self.bestMonths = bestMonths
    }

    public var coverImageURL: URL? { imageURLs.first }

    public var locationDisplay: String {
        countryCode.isEmpty ? "\(name), \(country)" : "\(name), \(countryCode)"
    }

    public var isHighlyRated: Bool { rating >= 4.5 }

    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.rating == rhs.rating
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#if DEBUG
public extension Destination {
    static var preview: Destination {
        Destination(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Kyoto",
            country: "Japan",
            countryCode: "JP",
            description: "Ancient temples, bamboo forests and timeless culture.",
            imageURLs: [URL(string: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800")!],
            coordinates: GeoCoordinate(latitude: 35.0116, longitude: 135.7681),
            rating: 4.9,
            reviewCount: 12483,
            isTrending: true,
            tags: ["cultural", "historic", "nature"],
            continent: "Asia",
            bestMonths: [3,4,10,11]
        )
    }
}
#endif
