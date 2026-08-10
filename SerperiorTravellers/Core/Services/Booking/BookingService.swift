import Foundation

public enum BookingServiceError: LocalizedError, Equatable {
    case networkError(String)
    case notFound(id: String)
    case bookingFailed(String)
    case cancellationFailed(String)
    case invalidParams(String)
    case unauthorized
    case rateLimited

    public var errorDescription: String? {
        switch self {
        case .networkError(let m): return "Network error: \(m)"
        case .notFound(let id): return "Booking not found: \(id)"
        case .bookingFailed(let m): return "Booking failed: \(m)"
        case .cancellationFailed(let m): return "Cancellation failed: \(m)"
        case .invalidParams(let m): return "Invalid params: \(m)"
        case .unauthorized: return "Unauthorized"
        case .rateLimited: return "Rate limited"
        }
    }
}

public protocol BookingServiceProtocol: Sendable {
    func searchHotels(params: HotelSearchParams) async throws -> HotelSearchResult
    func searchFlights(params: FlightSearchParams) async throws -> FlightSearchResult
    func searchCarRentals(params: CarRentalSearchParams) async throws -> CarRentalSearchResult

    func bookHotel(hotel: Hotel, params: HotelSearchParams, guestName: String, userId: UUID) async throws -> BookingConfirmation
    func bookFlight(flight: Flight, passengerName: String, userId: UUID) async throws -> BookingConfirmation
    func bookCar(rental: CarRental, driverName: String, userId: UUID) async throws -> BookingConfirmation

    func getBooking(id: UUID) async throws -> AnyBooking
    func getAllBookings(userId: UUID?) async throws -> [AnyBooking]
    func cancelBooking(id: UUID) async throws -> AnyBooking
}

public extension BookingServiceProtocol {
    func searchHotels(destination: String, checkIn: Date, checkOut: Date) async throws -> [Hotel] {
        let params = HotelSearchParams(destination: destination, checkIn: checkIn, checkOut: checkOut)
        return try await searchHotels(params: params).hotels
    }
}
