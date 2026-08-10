import Foundation

// MARK: - Search Params (service DTOs, UI-driven)

public struct HotelSearchParams: Codable, Sendable, Equatable {
    public var destination: String
    public var destinationId: UUID?
    public var latitude: Double?
    public var longitude: Double?
    public var checkIn: Date
    public var checkOut: Date
    public var guests: Int
    public var rooms: Int
    public var priceMin: Double?
    public var priceMax: Double?
    public var minRating: Double?
    public var currency: Currency

    public init(
        destination: String = "",
        destinationId: UUID? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        checkIn: Date = Date(),
        checkOut: Date = Date().addingTimeInterval(86400*2),
        guests: Int = 2,
        rooms: Int = 1,
        priceMin: Double? = nil,
        priceMax: Double? = nil,
        minRating: Double? = nil,
        currency: Currency = .usd
    ) {
        self.destination = destination
        self.destinationId = destinationId
        self.latitude = latitude
        self.longitude = longitude
        self.checkIn = checkIn
        self.checkOut = checkOut
        self.guests = guests
        self.rooms = rooms
        self.priceMin = priceMin
        self.priceMax = priceMax
        self.minRating = minRating
        self.currency = currency
    }
}

public struct FlightSearchParams: Codable, Sendable, Equatable {
    public var origin: String
    public var destination: String
    public var departureDate: Date
    public var returnDate: Date?
    public var adults: Int
    public var cabin: Cabin
    public var isOneWay: Bool
    public var currency: Currency

    public enum Cabin: String, Codable, Sendable, Equatable, CaseIterable { case economy, premiumEconomy, business, first }

    public init(
        origin: String = "SFO",
        destination: String = "HND",
        departureDate: Date = Date().addingTimeInterval(86400*7),
        returnDate: Date? = Date().addingTimeInterval(86400*14),
        adults: Int = 1,
        cabin: Cabin = .economy,
        isOneWay: Bool = false,
        currency: Currency = .usd
    ) {
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.adults = adults
        self.cabin = cabin
        self.isOneWay = isOneWay
        self.currency = currency
    }
}

public struct CarRentalSearchParams: Codable, Sendable, Equatable {
    public var pickupLocation: String
    public var dropoffLocation: String?
    public var pickupDate: Date
    public var dropoffDate: Date
    public var carType: String?
    public var currency: Currency

    public init(
        pickupLocation: String = "",
        dropoffLocation: String? = nil,
        pickupDate: Date = Date(),
        dropoffDate: Date = Date().addingTimeInterval(86400*3),
        carType: String? = nil,
        currency: Currency = .usd
    ) {
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.pickupDate = pickupDate
        self.dropoffDate = dropoffDate
        self.carType = carType
        self.currency = currency
    }
}

public struct HotelSearchResult: Sendable, Equatable {
    public var hotels: [Hotel]
    public var hasMore: Bool
    public var totalCount: Int
    public init(hotels: [Hotel], hasMore: Bool = false, totalCount: Int? = nil) {
        self.hotels = hotels; self.hasMore = hasMore; self.totalCount = totalCount ?? hotels.count
    }
}

public struct FlightSearchResult: Sendable, Equatable {
    public var flights: [Flight]
    public var hasMore: Bool
    public var totalCount: Int
    public init(flights: [Flight], hasMore: Bool = false, totalCount: Int? = nil) {
        self.flights = flights; self.hasMore = hasMore; self.totalCount = totalCount ?? flights.count
    }
}

public struct CarRentalSearchResult: Sendable, Equatable {
    public var rentals: [CarRental]
    public var hasMore: Bool
    public var totalCount: Int
    public init(rentals: [CarRental], hasMore: Bool = false, totalCount: Int? = nil) {
        self.rentals = rentals; self.hasMore = hasMore; self.totalCount = totalCount ?? rentals.count
    }
}

public struct BookingConfirmation: Codable, Sendable, Equatable {
    public let id: UUID
    public var booking: AnyBooking
    public var confirmationCode: String
    public var message: String
    public var createdAt: Date

    public init(id: UUID = UUID(), booking: AnyBooking, confirmationCode: String, message: String = "Booking confirmed", createdAt: Date = Date()) {
        self.id = id; self.booking = booking; self.confirmationCode = confirmationCode; self.message = message; self.createdAt = createdAt
    }
}
