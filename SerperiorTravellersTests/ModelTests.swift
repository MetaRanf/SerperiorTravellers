import XCTest
@testable import SerperiorTravellers
import CoreLocation

final class ModelTests: XCTestCase {
    func testCurrencySymbol() {
        XCTAssertEqual(Currency.usd.symbol, "$")
        XCTAssertEqual(Currency.eur.symbol, "€")
        XCTAssertEqual(Currency.jpy.displayName, "Japanese Yen")
    }

    func testMoneyCodableRoundTrip() throws {
        let m = Money(amount: Decimal(199.99), currency: .usd)
        let data = try JSONEncoder().encode(m)
        let back = try JSONDecoder().decode(Money.self, from: data)
        XCTAssertEqual(back, m)
        XCTAssertTrue(m.formatted.contains("$") || m.formatted.contains("199"))
    }

    func testGeoCoordinateCodableAndDistance() throws {
        let g = GeoCoordinate(latitude: 35.0116, longitude: 135.7681)
        let data = try JSONEncoder().encode(g)
        let back = try JSONDecoder().decode(GeoCoordinate.self, from: data)
        XCTAssertEqual(back, g)
        XCTAssertEqual(g.clCoordinate.latitude, 35.0116, accuracy: 0.001)
        let bali = GeoCoordinate(latitude: -8.4095, longitude: 115.1889)
        XCTAssertGreaterThan(g.distance(to: bali), 1000)
    }

    func testDestinationCodable() throws {
        let dest = Destination.preview
        let data = try JSONEncoder().encode(dest)
        let back = try JSONDecoder().decode(Destination.self, from: data)
        XCTAssertEqual(back.id, dest.id)
        XCTAssertEqual(back.name, dest.name)
        XCTAssertTrue(back.isHighlyRated)
    }

    func testPropertyCodable() throws {
        let prop = MockDataProvider.properties.first!
        let data = try JSONEncoder().encode(prop)
        let back = try JSONDecoder().decode(Property.self, from: data)
        XCTAssertEqual(back.id, prop.id)
        XCTAssertEqual(back.title, prop.title)
    }

    func testActivityCodableAndHot() throws {
        let act = MockDataProvider.activities.first!
        XCTAssertTrue(act.isHot)
        let data = try JSONEncoder().encode(act)
        let back = try JSONDecoder().decode(Activity.self, from: data)
        XCTAssertEqual(back.id, act.id)
    }

    func testWishlistItemPolymorphicCodable() throws {
        let item = WishlistItem.destinationItem(destinationId: UUID())
        let data = try JSONEncoder().encode(item)
        let back = try JSONDecoder().decode(WishlistItem.self, from: data)
        XCTAssertEqual(back.id, item.id)
        XCTAssertEqual(back.kind, .destination)
    }

    func testWishlistMutation() {
        var wl = Wishlist(userId: UUID(), title: "Test", type: .location)
        XCTAssertTrue(wl.isEmpty)
        let item = WishlistItem.destinationItem(destinationId: UUID())
        wl.addItem(item)
        XCTAssertEqual(wl.itemCount, 1)
        wl.removeItem(id: item.id)
        XCTAssertTrue(wl.isEmpty)
    }

    func testTripDurationAndProgress() {
        let trip = MockDataProvider.trips.first!
        XCTAssertGreaterThanOrEqual(trip.durationDays, 0)
        XCTAssertTrue(trip.progress >= 0 && trip.progress <= 1)
        XCTAssertFalse(trip.dateRangeDisplay.isEmpty)
    }

    func testAnyBookingCodable() throws {
        let hotel = MockDataProvider.MockBookingFactory.makeHotels().first!
        let booking = HotelBooking(hotel: hotel, userId: UUID(), status: .confirmed, confirmationCode: "HTL-111")
        let any = AnyBooking.hotel(booking)
        let data = try JSONEncoder().encode(any)
        let back = try JSONDecoder().decode(AnyBooking.self, from: data)
        XCTAssertEqual(back.id, any.id)
        XCTAssertEqual(back.type, .hotel)
    }

    func testFavoriteTypeIncludesPetFriendly() {
        XCTAssertTrue(FavoriteType.allCases.contains(.petFriendly))
        XCTAssertEqual(FavoriteType.petFriendly.displayName, "Pet Friendly")
    }

    func testWishlistTypeOrganization() {
        XCTAssertTrue(WishlistType.allCases.contains(.location))
        XCTAssertTrue(WishlistType.allCases.contains(.vacationType))
    }
}
