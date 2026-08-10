import XCTest
@testable import SerperiorTravellers

final class BookingServiceTests: XCTestCase {
    func testSearchHotelsReturnsDataWithZeroLatency() async throws {
        let service = MockBookingService(latency: .zero)
        let result = try await service.searchHotels(params: HotelSearchParams(destination: ""))
        XCTAssertFalse(result.hotels.isEmpty)
    }

    func testSearchFlightsFiltersByDestination() async throws {
        let service = MockBookingService(latency: .zero)
        let result = try await service.searchFlights(params: FlightSearchParams(origin: "", destination: "HND"))
        XCTAssertTrue(result.flights.allSatisfy { $0.toCode == "HND" || $0.toCode.localizedCaseInsensitiveContains("HND") })
    }

    func testBookAndCancelFlow() async throws {
        let service = MockBookingService(latency: .zero)
        let hotels = try await service.searchHotels(params: HotelSearchParams(destination: "")).hotels
        guard let hotel = hotels.first else { XCTFail("No hotels"); return }
        let confirmation = try await service.bookHotel(hotel: hotel, params: HotelSearchParams(destination: hotel.name), guestName: "Test User", userId: UUID())
        XCTAssertFalse(confirmation.confirmationCode.isEmpty)
        XCTAssertEqual(confirmation.booking.type, .hotel)

        let cancelled = try await service.cancelBooking(id: confirmation.booking.id)
        XCTAssertEqual(cancelled.status, .cancelled)
    }

    func testPriceTrackerZeroLatency() async throws {
        let tracker = MockPriceTrackerService(latency: .zero)
        let items = try await tracker.getTrackedItems()
        XCTAssertFalse(items.isEmpty)
        let results = try await tracker.checkPriceChanges()
        XCTAssertEqual(results.count, items.count)
    }
}
