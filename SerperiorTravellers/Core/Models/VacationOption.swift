import Foundation

public struct VacationOption: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var destination: Destination
    public var featuredProperties: [Property]
    public var featuredActivities: [Activity]
    public var totalPriceEstimate: Decimal
    public var currency: Currency
    public var nights: Int
    public var tagline: String?

    public var title: String { destination.name }
    public var destinationId: UUID { destination.id }
    public var coverImageURL: URL? { destination.coverImageURL ?? featuredProperties.first?.coverImageURL }
    public var isTrending: Bool { destination.isTrending || featuredProperties.contains(where: \.isTrending) || featuredActivities.contains(where: \.isHot) }

    public var averageRating: Double {
        let vals = [destination.rating] + featuredProperties.map(\.rating) + featuredActivities.map(\.rating)
        return vals.isEmpty ? 0 : vals.reduce(0,+) / Double(vals.count)
    }

    public var pricePerNightEstimate: Decimal {
        guard nights > 0 else { return totalPriceEstimate }
        return totalPriceEstimate / Decimal(nights)
    }

    public var tags: [String] { destination.tags }

    public init(
        id: UUID = UUID(),
        destination: Destination,
        featuredProperties: [Property] = [],
        featuredActivities: [Activity] = [],
        totalPriceEstimate: Decimal,
        currency: Currency = .usd,
        nights: Int = 5,
        tagline: String? = nil
    ) {
        self.id = id
        self.destination = destination
        self.featuredProperties = featuredProperties
        self.featuredActivities = featuredActivities
        self.totalPriceEstimate = totalPriceEstimate
        self.currency = currency
        self.nights = nights
        self.tagline = tagline
    }

    private enum CodingKeys: String, CodingKey {
        case id, destination, featuredProperties, featuredActivities, totalPriceEstimate, currency, nights, tagline
    }

    public static func == (lhs: VacationOption, rhs: VacationOption) -> Bool {
        lhs.id == rhs.id && lhs.totalPriceEstimate == rhs.totalPriceEstimate
    }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
