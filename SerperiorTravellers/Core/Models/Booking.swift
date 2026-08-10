import Foundation

public enum BookingStatus: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case pending = "pending", confirmed = "confirmed", checkedIn = "checked_in",
         checkedOut = "checked_out", cancelled = "cancelled", failed = "failed", refunded = "refunded"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .checkedIn: return "Checked In"
        case .checkedOut: return "Checked Out"
        case .cancelled: return "Cancelled"
        case .failed: return "Failed"
        case .refunded: return "Refunded"
        }
    }
    public var isTerminal: Bool {
        switch self { case .cancelled, .failed, .refunded, .checkedOut: return true; default: return false }
    }
}

public enum BookingType: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case hotel = "hotel", flight = "flight", carRental = "car_rental", activity = "activity"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .hotel: return "Hotel"
        case .flight: return "Flight"
        case .carRental: return "Car Rental"
        case .activity: return "Activity"
        }
    }
    public var systemIcon: String {
        switch self {
        case .hotel: return "bed.double"
        case .flight: return "airplane"
        case .carRental: return "car"
        case .activity: return "ticket"
        }
    }
}

public protocol Bookable: Identifiable, Codable, Equatable, Sendable {
    var id: UUID { get }
    var bookingType: BookingType { get }
    var title: String { get }
    var totalPrice: Decimal { get }
    var currency: Currency { get }
    var status: BookingStatus { get }
    var createdAt: Date { get }
}

// MARK: - Domain Bookables

public struct Flight: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var airline: String
    public var flightNumber: String
    public var fromCode: String
    public var toCode: String
    public var departureAt: Date
    public var arrivalAt: Date
    public var durationMinutes: Int
    public var price: Money
    public var cabinClass: String
    public var stops: Int

    public init(
        id: UUID = UUID(),
        airline: String,
        flightNumber: String,
        fromCode: String,
        toCode: String,
        departureAt: Date,
        arrivalAt: Date,
        durationMinutes: Int,
        price: Money,
        cabinClass: String = "Economy",
        stops: Int = 0
    ) {
        self.id = id; self.airline = airline; self.flightNumber = flightNumber
        self.fromCode = fromCode; self.toCode = toCode
        self.departureAt = departureAt; self.arrivalAt = arrivalAt
        self.durationMinutes = durationMinutes; self.price = price
        self.cabinClass = cabinClass; self.stops = stops
    }
}

public struct Hotel: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var propertyId: UUID
    public var name: String
    public var checkIn: Date
    public var checkOut: Date
    public var pricePerNight: Money
    public var totalPrice: Money
    public var guests: Int
    public var rooms: Int

    public init(
        id: UUID = UUID(),
        propertyId: UUID,
        name: String,
        checkIn: Date,
        checkOut: Date,
        pricePerNight: Money,
        totalPrice: Money,
        guests: Int = 2,
        rooms: Int = 1
    ) {
        self.id = id; self.propertyId = propertyId; self.name = name
        self.checkIn = checkIn; self.checkOut = checkOut
        self.pricePerNight = pricePerNight; self.totalPrice = totalPrice
        self.guests = guests; self.rooms = rooms
    }
}

public struct CarRental: Identifiable, Codable, Equatable, Sendable, Hashable {
    public let id: UUID
    public var company: String
    public var carModel: String
    public var carType: String
    public var pickupLocation: String
    public var dropoffLocation: String
    public var pickupDate: Date
    public var dropoffDate: Date
    public var price: Money

    public init(
        id: UUID = UUID(),
        company: String,
        carModel: String,
        carType: String = "Sedan",
        pickupLocation: String,
        dropoffLocation: String,
        pickupDate: Date,
        dropoffDate: Date,
        price: Money
    ) {
        self.id = id; self.company = company; self.carModel = carModel
        self.carType = carType; self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation; self.pickupDate = pickupDate
        self.dropoffDate = dropoffDate; self.price = price
    }
}

// MARK: - Booking wrappers

public struct HotelBooking: Bookable, Hashable {
    public let id: UUID
    public var bookingType: BookingType = .hotel
    public var title: String { hotel.name }
    public var totalPrice: Decimal { hotel.totalPrice.amount }
    public var currency: Currency { hotel.totalPrice.currency }
    public var status: BookingStatus
    public var createdAt: Date
    public var updatedAt: Date
    public var hotel: Hotel
    public var userId: UUID
    public var tripId: UUID?
    public var confirmationCode: String?
    public var notes: String?

    public init(
        id: UUID = UUID(),
        hotel: Hotel,
        userId: UUID,
        tripId: UUID? = nil,
        status: BookingStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        confirmationCode: String? = nil,
        notes: String? = nil
    ) {
        self.id = id; self.hotel = hotel; self.userId = userId; self.tripId = tripId
        self.status = status; self.createdAt = createdAt; self.updatedAt = updatedAt
        self.confirmationCode = confirmationCode; self.notes = notes
    }
}

public struct FlightBooking: Bookable, Hashable {
    public let id: UUID
    public var bookingType: BookingType = .flight
    public var title: String { "\(outbound.airline) \(outbound.flightNumber)" }
    public var totalPrice: Decimal { price.amount }
    public var currency: Currency { price.currency }
    public var status: BookingStatus
    public var createdAt: Date
    public var updatedAt: Date
    public var outbound: Flight
    public var inbound: Flight?
    public var price: Money
    public var userId: UUID
    public var tripId: UUID?
    public var passengers: [String]
    public var confirmationCode: String?

    public init(
        id: UUID = UUID(),
        outbound: Flight,
        inbound: Flight? = nil,
        price: Money,
        userId: UUID,
        tripId: UUID? = nil,
        status: BookingStatus = .pending,
        passengers: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        confirmationCode: String? = nil
    ) {
        self.id = id; self.outbound = outbound; self.inbound = inbound; self.price = price
        self.userId = userId; self.tripId = tripId; self.status = status
        self.passengers = passengers; self.createdAt = createdAt; self.updatedAt = updatedAt
        self.confirmationCode = confirmationCode
    }
}

public struct CarRentalBooking: Bookable, Hashable {
    public let id: UUID
    public var bookingType: BookingType = .carRental
    public var title: String { "\(carRental.company) – \(carRental.carModel)" }
    public var totalPrice: Decimal { carRental.price.amount }
    public var currency: Currency { carRental.price.currency }
    public var status: BookingStatus
    public var createdAt: Date
    public var updatedAt: Date
    public var carRental: CarRental
    public var userId: UUID
    public var tripId: UUID?
    public var confirmationCode: String?

    public init(
        id: UUID = UUID(),
        carRental: CarRental,
        userId: UUID,
        tripId: UUID? = nil,
        status: BookingStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        confirmationCode: String? = nil
    ) {
        self.id = id; self.carRental = carRental; self.userId = userId; self.tripId = tripId
        self.status = status; self.createdAt = createdAt; self.updatedAt = updatedAt
        self.confirmationCode = confirmationCode
    }
}

public struct ActivityBooking: Bookable, Hashable {
    public let id: UUID
    public var bookingType: BookingType = .activity
    public var title: String
    public var totalPrice: Decimal
    public var currency: Currency
    public var status: BookingStatus
    public var createdAt: Date
    public var updatedAt: Date
    public var activityId: UUID
    public var scheduledAt: Date
    public var participants: Int
    public var userId: UUID
    public var tripId: UUID?

    public init(
        id: UUID = UUID(),
        title: String,
        totalPrice: Decimal,
        currency: Currency = .usd,
        status: BookingStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        activityId: UUID,
        scheduledAt: Date,
        participants: Int = 1,
        userId: UUID,
        tripId: UUID? = nil
    ) {
        self.id = id; self.title = title; self.totalPrice = totalPrice; self.currency = currency
        self.status = status; self.createdAt = createdAt; self.updatedAt = updatedAt
        self.activityId = activityId; self.scheduledAt = scheduledAt; self.participants = participants
        self.userId = userId; self.tripId = tripId
    }
}

public enum AnyBooking: Identifiable, Codable, Equatable, Sendable, Hashable {
    case hotel(HotelBooking)
    case flight(FlightBooking)
    case carRental(CarRentalBooking)
    case activity(ActivityBooking)

    public var id: UUID {
        switch self {
        case .hotel(let b): return b.id
        case .flight(let b): return b.id
        case .carRental(let b): return b.id
        case .activity(let b): return b.id
        }
    }

    public var type: BookingType {
        switch self {
        case .hotel: return .hotel
        case .flight: return .flight
        case .carRental: return .carRental
        case .activity: return .activity
        }
    }

    public var status: BookingStatus {
        switch self {
        case .hotel(let b): return b.status
        case .flight(let b): return b.status
        case .carRental(let b): return b.status
        case .activity(let b): return b.status
        }
    }

    private enum CodingKeys: String, CodingKey { case type, payload }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let t = try c.decode(BookingType.self, forKey: .type)
        switch t {
        case .hotel: self = .hotel(try c.decode(HotelBooking.self, forKey: .payload))
        case .flight: self = .flight(try c.decode(FlightBooking.self, forKey: .payload))
        case .carRental: self = .carRental(try c.decode(CarRentalBooking.self, forKey: .payload))
        case .activity: self = .activity(try c.decode(ActivityBooking.self, forKey: .payload))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type, forKey: .type)
        switch self {
        case .hotel(let b): try c.encode(b, forKey: .payload)
        case .flight(let b): try c.encode(b, forKey: .payload)
        case .carRental(let b): try c.encode(b, forKey: .payload)
        case .activity(let b): try c.encode(b, forKey: .payload)
        }
    }
}
