import Foundation

public actor MockBookingService: BookingServiceProtocol {
    private var bookings: [AnyBooking] = []
    private var hotels: [Hotel] = []
    private var flights: [Flight] = []
    private var carRentals: [CarRental] = []

    public var latency: Duration = .zero

    public init(latency: Duration = .zero, preload: Bool = true) {
        self.latency = latency
        if preload {
            self.hotels = Self.makeMockHotels()
            self.flights = Self.makeMockFlights()
            self.carRentals = Self.makeMockCars()
            self.bookings = Self.makeMockInitialBookings(hotels: hotels, flights: flights, cars: carRentals)
        }
    }

    private func simulateLatencyIfNeeded() async {
        guard latency > .zero else { return }
        try? await Task.sleep(for: latency)
    }

    // MARK: Search

    public func searchHotels(params: HotelSearchParams) async throws -> HotelSearchResult {
        await simulateLatencyIfNeeded()
        var filtered = hotels
        if !params.destination.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(params.destination) }
        }
        if let min = params.priceMin {
            filtered = filtered.filter { NSDecimalNumber(decimal: $0.totalPrice.amount).doubleValue >= min }
        }
        if let max = params.priceMax {
            filtered = filtered.filter { NSDecimalNumber(decimal: $0.totalPrice.amount).doubleValue <= max }
        }
        return HotelSearchResult(hotels: filtered)
    }

    public func searchFlights(params: FlightSearchParams) async throws -> FlightSearchResult {
        await simulateLatencyIfNeeded()
        var filtered = flights
        if !params.origin.isEmpty {
            filtered = filtered.filter { $0.fromCode == params.origin || $0.fromCode.localizedCaseInsensitiveContains(params.origin) }
        }
        if !params.destination.isEmpty {
            filtered = filtered.filter { $0.toCode == params.destination || $0.toCode.localizedCaseInsensitiveContains(params.destination) }
        }
        return FlightSearchResult(flights: filtered)
    }

    public func searchCarRentals(params: CarRentalSearchParams) async throws -> CarRentalSearchResult {
        await simulateLatencyIfNeeded()
        var filtered = carRentals
        if let type = params.carType {
            filtered = filtered.filter { $0.carType.localizedCaseInsensitiveContains(type) }
        }
        if !params.pickupLocation.isEmpty {
            filtered = filtered.filter { $0.pickupLocation.localizedCaseInsensitiveContains(params.pickupLocation) }
        }
        return CarRentalSearchResult(rentals: filtered)
    }

    // MARK: Booking

    public func bookHotel(hotel: Hotel, params: HotelSearchParams, guestName: String, userId: UUID) async throws -> BookingConfirmation {
        await simulateLatencyIfNeeded()
        let booking = HotelBooking(
            id: UUID(), hotel: hotel, userId: userId, status: .confirmed,
            confirmationCode: "HTL-\(Int.random(in: 100000...999999))",
            notes: "Guest: \(guestName)"
        )
        let wrapper = AnyBooking.hotel(booking)
        bookings.append(wrapper)
        return BookingConfirmation(booking: wrapper, confirmationCode: booking.confirmationCode ?? "HTL-000000")
    }

    public func bookFlight(flight: Flight, passengerName: String, userId: UUID) async throws -> BookingConfirmation {
        await simulateLatencyIfNeeded()
        let booking = FlightBooking(
            id: UUID(), outbound: flight, price: flight.price, userId: userId, status: .confirmed,
            passengers: [passengerName],
            confirmationCode: "FLT-\(Int.random(in: 100000...999999))"
        )
        let wrapper = AnyBooking.flight(booking)
        bookings.append(wrapper)
        return BookingConfirmation(booking: wrapper, confirmationCode: booking.confirmationCode ?? "FLT-000000")
    }

    public func bookCar(rental: CarRental, driverName: String, userId: UUID) async throws -> BookingConfirmation {
        await simulateLatencyIfNeeded()
        let booking = CarRentalBooking(id: UUID(), carRental: rental, userId: userId, status: .confirmed, confirmationCode: "CAR-\(Int.random(in: 100000...999999))")
        let wrapper = AnyBooking.carRental(booking)
        bookings.append(wrapper)
        return BookingConfirmation(booking: wrapper, confirmationCode: booking.confirmationCode ?? "CAR-000000")
    }

    // MARK: Management

    public func getBooking(id: UUID) async throws -> AnyBooking {
        await simulateLatencyIfNeeded()
        guard let b = bookings.first(where: { $0.id == id }) else {
            throw BookingServiceError.notFound(id: id.uuidString)
        }
        return b
    }

    public func getAllBookings(userId: UUID?) async throws -> [AnyBooking] {
        await simulateLatencyIfNeeded()
        if let uid = userId {
            return bookings.filter {
                switch $0 {
                case .hotel(let hb): return hb.userId == uid
                case .flight(let fb): return fb.userId == uid
                case .carRental(let cb): return cb.userId == uid
                case .activity(let ab): return ab.userId == uid
                }
            }
        }
        return bookings
    }

    public func cancelBooking(id: UUID) async throws -> AnyBooking {
        await simulateLatencyIfNeeded()
        guard let idx = bookings.firstIndex(where: { $0.id == id }) else {
            throw BookingServiceError.notFound(id: id.uuidString)
        }
        var booking = bookings[idx]
        switch booking {
        case .hotel(var hb):
            guard hb.status == .confirmed || hb.status == .pending else { throw BookingServiceError.cancellationFailed("Cannot cancel status \(hb.status)") }
            hb.status = .cancelled; booking = .hotel(hb)
        case .flight(var fb):
            guard fb.status == .confirmed || fb.status == .pending else { throw BookingServiceError.cancellationFailed("Cannot cancel") }
            fb.status = .cancelled; booking = .flight(fb)
        case .carRental(var cb):
            cb.status = .cancelled; booking = .carRental(cb)
        case .activity(var ab):
            ab.status = .cancelled; booking = .activity(ab)
        }
        bookings[idx] = booking
        return booking
    }

    // MARK: Factory

    public static func makeMockHotels() -> [Hotel] {
        return MockDataProvider.MockBookingFactory.makeHotels()
    }
    public static func makeMockFlights() -> [Flight] {
        return MockDataProvider.MockBookingFactory.makeFlights()
    }
    public static func makeMockCars() -> [CarRental] {
        return MockDataProvider.MockBookingFactory.makeCars()
    }
    public static func makeMockInitialBookings(hotels: [Hotel], flights: [Flight], cars: [CarRental]) -> [AnyBooking] {
        var result: [AnyBooking] = []
        let userId = MockDataProvider.currentUser.id
        if let h = hotels.first {
            let hb = HotelBooking(hotel: h, userId: userId, status: .confirmed, confirmationCode: "HTL-123456")
            result.append(.hotel(hb))
        }
        if let f = flights.first {
            let fb = FlightBooking(outbound: f, price: f.price, userId: userId, status: .confirmed, confirmationCode: "FLT-654321")
            result.append(.flight(fb))
        }
        return result
    }
}
