import Foundation

public enum AlertType: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case weather = "weather", news = "news", booking = "booking", price = "price", trip = "trip", system = "system"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .weather: return "Weather"
        case .news: return "News"
        case .booking: return "Booking"
        case .price: return "Price Drop"
        case .trip: return "Trip Update"
        case .system: return "System"
        }
    }
    public var systemIcon: String {
        switch self {
        case .weather: return "cloud.bolt"
        case .news: return "newspaper"
        case .booking: return "ticket"
        case .price: return "tag"
        case .trip: return "airplane"
        case .system: return "info.circle"
        }
    }
}

public enum AlertSeverity: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable, Comparable {
    case info = "info", low = "low", medium = "medium", high = "high", critical = "critical"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .info: return "Info"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    public var rank: Int {
        switch self {
        case .info: return 0; case .low: return 1; case .medium: return 2; case .high: return 3; case .critical: return 4
        }
    }
    public static func < (lhs: AlertSeverity, rhs: AlertSeverity) -> Bool { lhs.rank < rhs.rank }
}

public protocol AlertProtocol: Identifiable, Codable, Equatable, Sendable {
    var id: UUID { get }
    var type: AlertType { get }
    var severity: AlertSeverity { get }
    var title: String { get }
    var message: String { get }
    var createdAt: Date { get }
    var isRead: Bool { get }
}

public struct WeatherAlert: AlertProtocol, Hashable {
    public let id: UUID
    public var type: AlertType = .weather
    public var severity: AlertSeverity
    public var title: String
    public var message: String
    public var createdAt: Date
    public var isRead: Bool
    public var destinationId: UUID?
    public var coordinates: GeoCoordinate?
    public var condition: String
    public var temperature: Double?
    public var expiresAt: Date?
    public var source: String?

    public init(
        id: UUID = UUID(),
        severity: AlertSeverity = .medium,
        title: String,
        message: String,
        createdAt: Date = Date(),
        isRead: Bool = false,
        destinationId: UUID? = nil,
        coordinates: GeoCoordinate? = nil,
        condition: String,
        temperature: Double? = nil,
        expiresAt: Date? = nil,
        source: String? = nil
    ) {
        self.id = id; self.severity = severity; self.title = title; self.message = message
        self.createdAt = createdAt; self.isRead = isRead; self.destinationId = destinationId
        self.coordinates = coordinates; self.condition = condition; self.temperature = temperature
        self.expiresAt = expiresAt; self.source = source
    }
}

public struct NewsAlert: AlertProtocol, Hashable {
    public let id: UUID
    public var type: AlertType = .news
    public var severity: AlertSeverity
    public var title: String
    public var message: String
    public var createdAt: Date
    public var isRead: Bool
    public var destinationId: UUID?
    public var newsURL: URL?
    public var category: String?
    public var publishedAt: Date?
    public var publisher: String?

    public init(
        id: UUID = UUID(),
        severity: AlertSeverity = .info,
        title: String,
        message: String,
        createdAt: Date = Date(),
        isRead: Bool = false,
        destinationId: UUID? = nil,
        newsURL: URL? = nil,
        category: String? = nil,
        publishedAt: Date? = nil,
        publisher: String? = nil
    ) {
        self.id = id; self.severity = severity; self.title = title; self.message = message
        self.createdAt = createdAt; self.isRead = isRead; self.destinationId = destinationId
        self.newsURL = newsURL; self.category = category; self.publishedAt = publishedAt; self.publisher = publisher
    }
}

public struct BookingAlert: AlertProtocol, Hashable {
    public let id: UUID
    public var type: AlertType = .booking
    public var severity: AlertSeverity
    public var title: String
    public var message: String
    public var createdAt: Date
    public var isRead: Bool
    public var bookingId: UUID
    public var bookingType: BookingType
    public var bookingStatus: BookingStatus
    public var actionRequired: Bool
    public var ctaURL: URL?

    public init(
        id: UUID = UUID(),
        severity: AlertSeverity = .high,
        title: String,
        message: String,
        createdAt: Date = Date(),
        isRead: Bool = false,
        bookingId: UUID,
        bookingType: BookingType,
        bookingStatus: BookingStatus,
        actionRequired: Bool = false,
        ctaURL: URL? = nil
    ) {
        self.id = id; self.severity = severity; self.title = title; self.message = message
        self.createdAt = createdAt; self.isRead = isRead; self.bookingId = bookingId
        self.bookingType = bookingType; self.bookingStatus = bookingStatus
        self.actionRequired = actionRequired; self.ctaURL = ctaURL
    }
}

public struct PriceAlert: AlertProtocol, Hashable {
    public let id: UUID
    public var type: AlertType = .price
    public var severity: AlertSeverity
    public var title: String
    public var message: String
    public var createdAt: Date
    public var isRead: Bool
    public var relatedId: UUID
    public var relatedType: BookingType
    public var oldPrice: Money
    public var newPrice: Money
    public var dropPercentage: Double
    public var expiresAt: Date?

    public init(
        id: UUID = UUID(),
        severity: AlertSeverity = .low,
        title: String,
        message: String,
        createdAt: Date = Date(),
        isRead: Bool = false,
        relatedId: UUID,
        relatedType: BookingType,
        oldPrice: Money,
        newPrice: Money,
        expiresAt: Date? = nil
    ) {
        self.id = id; self.severity = severity; self.title = title; self.message = message
        self.createdAt = createdAt; self.isRead = isRead; self.relatedId = relatedId
        self.relatedType = relatedType; self.oldPrice = oldPrice; self.newPrice = newPrice
        self.dropPercentage = oldPrice.amount > 0 ?
            (1 - (NSDecimalNumber(decimal: newPrice.amount).doubleValue / NSDecimalNumber(decimal: oldPrice.amount).doubleValue)) * 100 : 0
        self.expiresAt = expiresAt
    }

    public var isPriceDrop: Bool { newPrice.amount < oldPrice.amount }
    public var savings: Money {
        let diff = oldPrice.amount - newPrice.amount
        return Money(amount: max(0, diff), currency: newPrice.currency)
    }
}

public enum AnyAlert: Identifiable, Codable, Equatable, Sendable, Hashable {
    case weather(WeatherAlert), news(NewsAlert), booking(BookingAlert), price(PriceAlert)

    public var id: UUID {
        switch self {
        case .weather(let a): return a.id
        case .news(let a): return a.id
        case .booking(let a): return a.id
        case .price(let a): return a.id
        }
    }

    public var type: AlertType {
        switch self { case .weather: return .weather; case .news: return .news; case .booking: return .booking; case .price: return .price }
    }

    public var severity: AlertSeverity {
        switch self { case .weather(let a): return a.severity; case .news(let a): return a.severity; case .booking(let a): return a.severity; case .price(let a): return a.severity }
    }

    public var createdAt: Date {
        switch self { case .weather(let a): return a.createdAt; case .news(let a): return a.createdAt; case .booking(let a): return a.createdAt; case .price(let a): return a.createdAt }
    }

    public var isRead: Bool {
        switch self { case .weather(let a): return a.isRead; case .news(let a): return a.isRead; case .booking(let a): return a.isRead; case .price(let a): return a.isRead }
    }

    private enum CodingKeys: String, CodingKey { case type, payload }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let t = try c.decode(AlertType.self, forKey: .type)
        switch t {
        case .weather: self = .weather(try c.decode(WeatherAlert.self, forKey: .payload))
        case .news: self = .news(try c.decode(NewsAlert.self, forKey: .payload))
        case .booking: self = .booking(try c.decode(BookingAlert.self, forKey: .payload))
        case .price: self = .price(try c.decode(PriceAlert.self, forKey: .payload))
        case .trip, .system:
            if let wa = try? c.decode(WeatherAlert.self, forKey: .payload) { self = .weather(wa) }
            else { self = .news(try c.decode(NewsAlert.self, forKey: .payload)) }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type, forKey: .type)
        switch self {
        case .weather(let a): try c.encode(a, forKey: .payload)
        case .news(let a): try c.encode(a, forKey: .payload)
        case .booking(let a): try c.encode(a, forKey: .payload)
        case .price(let a): try c.encode(a, forKey: .payload)
        }
    }
}

// Flat UI helper alias for simple alert lists
public struct SimpleAppAlert: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var title: String
    public var message: String
    public var type: AlertType
    public var severity: AlertSeverity
    public var timestamp: Date
    public var destinationId: UUID?
    public var tripId: UUID?
    public var isRead: Bool
    public var actionURL: URL?

    public init(id: UUID = UUID(), title: String, message: String, type: AlertType, severity: AlertSeverity = .info, timestamp: Date = Date(), destinationId: UUID? = nil, tripId: UUID? = nil, isRead: Bool = false, actionURL: URL? = nil) {
        self.id = id; self.title = title; self.message = message; self.type = type; self.severity = severity
        self.timestamp = timestamp; self.destinationId = destinationId; self.tripId = tripId; self.isRead = isRead; self.actionURL = actionURL
    }
}

public typealias AppAlert = SimpleAppAlert

// Storage light helpers
public struct RecentSearch: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public var query: String
    public var timestamp: Date
    public var type: SearchType
    public enum SearchType: String, Codable, Sendable { case destination, hotel, flight, activity }
    public init(id: String = UUID().uuidString, query: String, timestamp: Date = Date(), type: SearchType = .destination) {
        self.id = id; self.query = query; self.timestamp = timestamp; self.type = type
    }
}

public struct TrackedPriceItem: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public var type: BookingType
    public var referenceId: UUID
    public var originalPrice: Decimal
    public var currentPrice: Decimal
    public var currency: Currency
    public var lastChecked: Date

    public var priceDrop: Decimal { originalPrice - currentPrice }
    public var priceDropPercent: Double {
        guard originalPrice != 0 else { return 0 }
        let orig = NSDecimalNumber(decimal: originalPrice).doubleValue
        let curr = NSDecimalNumber(decimal: currentPrice).doubleValue
        return ((orig - curr) / orig) * 100
    }

    public init(id: UUID = UUID(), type: BookingType, referenceId: UUID, originalPrice: Decimal, currentPrice: Decimal, currency: Currency = .usd, lastChecked: Date = Date()) {
        self.id = id; self.type = type; self.referenceId = referenceId
        self.originalPrice = originalPrice; self.currentPrice = currentPrice
        self.currency = currency; self.lastChecked = lastChecked
    }
}
