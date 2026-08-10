import Foundation

public enum PropertyType: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case hotel = "hotel", villa = "villa", apartment = "apartment", resort = "resort",
         cabin = "cabin", cottage = "cottage", hostel = "hostel", lodge = "lodge"
    public var id: String { rawValue }
    public var displayName: String { rawValue.capitalized }
    public var systemIcon: String {
        switch self {
        case .hotel: return "building.2"
        case .villa: return "house.lodge"
        case .apartment: return "building.columns"
        case .resort: return "beach.umbrella"
        case .cabin: return "tree"
        case .cottage: return "house"
        case .hostel: return "bed.double"
        case .lodge: return "mountain.2"
        }
    }
}

public enum Amenity: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case wifi = "wifi", pool = "pool", kitchen = "kitchen", ac = "ac", parking = "parking",
         gym = "gym", spa = "spa", beachfront = "beachfront", petFriendly = "pet_friendly",
         breakfast = "breakfast", laundry = "laundry", workspace = "workspace"

    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .pool: return "Pool"
        case .kitchen: return "Kitchen"
        case .ac: return "Air Conditioning"
        case .parking: return "Parking"
        case .gym: return "Gym"
        case .spa: return "Spa"
        case .beachfront: return "Beachfront"
        case .petFriendly: return "Pet Friendly"
        case .breakfast: return "Breakfast"
        case .laundry: return "Laundry"
        case .workspace: return "Workspace"
        }
    }
    public var systemIcon: String {
        switch self {
        case .wifi: return "wifi"
        case .pool: return "drop.fill"
        case .kitchen: return "fork.knife"
        case .ac: return "snowflake"
        case .parking: return "car"
        case .gym: return "dumbbell"
        case .spa: return "heart"
        case .beachfront: return "beach.umbrella"
        case .petFriendly: return "pawprint.fill"
        case .breakfast: return "cup.and.saucer.fill"
        case .laundry: return "washer"
        case .workspace: return "desktopcomputer"
        }
    }
}

public struct Property: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var title: String
    public var destinationId: UUID
    public var type: PropertyType
    public var pricePerNight: Decimal
    public var currency: Currency
    public var rating: Double
    public var reviewCount: Int
    public var imageURLs: [URL]
    public var amenities: Set<Amenity>
    public var coordinates: GeoCoordinate
    public var isSuperhost: Bool
    public var isTrending: Bool
    public var hostId: UUID?
    public var description: String
    public var maxGuests: Int
    public var bedrooms: Int
    public var beds: Int
    public var bathrooms: Double
    public var address: String?
    public var instantBook: Bool
    public var cancellationPolicy: String?

    public init(
        id: UUID = UUID(),
        title: String,
        destinationId: UUID,
        type: PropertyType,
        pricePerNight: Decimal,
        currency: Currency = .usd,
        rating: Double = 0,
        reviewCount: Int = 0,
        imageURLs: [URL] = [],
        amenities: Set<Amenity> = [],
        coordinates: GeoCoordinate,
        isSuperhost: Bool = false,
        isTrending: Bool = false,
        hostId: UUID? = nil,
        description: String = "",
        maxGuests: Int = 2,
        bedrooms: Int = 1,
        beds: Int = 1,
        bathrooms: Double = 1,
        address: String? = nil,
        instantBook: Bool = true,
        cancellationPolicy: String? = "Flexible"
    ) {
        self.id = id
        self.title = title
        self.destinationId = destinationId
        self.type = type
        self.pricePerNight = pricePerNight
        self.currency = currency
        self.rating = rating
        self.reviewCount = reviewCount
        self.imageURLs = imageURLs
        self.amenities = amenities
        self.coordinates = coordinates
        self.isSuperhost = isSuperhost
        self.isTrending = isTrending
        self.hostId = hostId
        self.description = description
        self.maxGuests = maxGuests
        self.bedrooms = bedrooms
        self.beds = beds
        self.bathrooms = bathrooms
        self.address = address
        self.instantBook = instantBook
        self.cancellationPolicy = cancellationPolicy
    }

    public var coverImageURL: URL? { imageURLs.first }
    public var pricePerNightDouble: Double { NSDecimalNumber(decimal: pricePerNight).doubleValue }
    public func totalPrice(for nights: Int) -> Decimal { pricePerNight * Decimal(nights) }
    public var isLuxury: Bool { pricePerNightDouble > 500 }
    public var formattedRating: String { String(format: "%.1f", rating) }

    public static func == (lhs: Property, rhs: Property) -> Bool {
        lhs.id == rhs.id && lhs.pricePerNight == rhs.pricePerNight && lhs.rating == rhs.rating
    }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
