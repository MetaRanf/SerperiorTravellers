import Foundation

public enum ActivityCategory: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case sightseeing = "sightseeing", adventure = "adventure", food = "food", culture = "culture",
         nature = "nature", nightlife = "nightlife", wellness = "wellness", sports = "sports",
         shopping = "shopping", family = "family"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .sightseeing: return "Sightseeing"
        case .adventure: return "Adventure"
        case .food: return "Food & Drink"
        case .culture: return "Culture"
        case .nature: return "Nature"
        case .nightlife: return "Nightlife"
        case .wellness: return "Wellness"
        case .sports: return "Sports"
        case .shopping: return "Shopping"
        case .family: return "Family"
        }
    }
    public var systemIcon: String {
        switch self {
        case .sightseeing: return "binoculars"
        case .adventure: return "mountain.2.fill"
        case .food: return "fork.knife"
        case .culture: return "building.columns"
        case .nature: return "leaf"
        case .nightlife: return "moon.stars"
        case .wellness: return "heart"
        case .sports: return "figure.run"
        case .shopping: return "bag"
        case .family: return "person.2"
        }
    }
}

public enum Season: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case spring = "spring", summer = "summer", autumn = "autumn", winter = "winter", allYear = "all_year"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .spring: return "Spring"
        case .summer: return "Summer"
        case .autumn: return "Autumn"
        case .winter: return "Winter"
        case .allYear: return "All Year"
        }
    }
}

public struct ActivityDuration: Codable, Equatable, Sendable, Hashable {
    public var minutes: Int
    public init(minutes: Int) { self.minutes = max(0, minutes) }
    public init(hours: Double) { self.minutes = Int(hours * 60) }
    public var hours: Double { Double(minutes) / 60.0 }
    public var displayString: String {
        if minutes < 60 { return "\(minutes) min" }
        let h = minutes / 60
        let m = minutes % 60
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }
}

public struct Activity: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var title: String
    public var destinationId: UUID
    public var description: String
    public var category: ActivityCategory
    public var price: Decimal
    public var currency: Currency
    public var duration: ActivityDuration
    public var rating: Double
    public var reviewCount: Int
    public var imageURLs: [URL]
    public var coordinates: GeoCoordinate?
    public var isHot: Bool
    public var recommendedSeason: Season
    public var tags: [String]
    public var maxParticipants: Int?
    public var isFreeCancellation: Bool
    public var provider: String?

    public init(
        id: UUID = UUID(),
        title: String,
        destinationId: UUID,
        description: String,
        category: ActivityCategory,
        price: Decimal,
        currency: Currency = .usd,
        duration: ActivityDuration,
        rating: Double = 0,
        reviewCount: Int = 0,
        imageURLs: [URL] = [],
        coordinates: GeoCoordinate? = nil,
        isHot: Bool = false,
        recommendedSeason: Season = .allYear,
        tags: [String] = [],
        maxParticipants: Int? = nil,
        isFreeCancellation: Bool = true,
        provider: String? = nil
    ) {
        self.id = id
        self.title = title
        self.destinationId = destinationId
        self.description = description
        self.category = category
        self.price = price
        self.currency = currency
        self.duration = duration
        self.rating = rating
        self.reviewCount = reviewCount
        self.imageURLs = imageURLs
        self.coordinates = coordinates
        self.isHot = isHot
        self.recommendedSeason = recommendedSeason
        self.tags = tags
        self.maxParticipants = maxParticipants
        self.isFreeCancellation = isFreeCancellation
        self.provider = provider
    }

    public var coverImageURL: URL? { imageURLs.first }
    public var priceDouble: Double { NSDecimalNumber(decimal: price).doubleValue }
    public var formattedPrice: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currency.rawValue
        return f.string(from: NSDecimalNumber(decimal: price)) ?? "\(currency.symbol)\(price)"
    }

    public static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id && lhs.price == rhs.price && lhs.rating == rhs.rating
    }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
