import XCTest
@testable import SerperiorTravellers

final class AIServiceTests: XCTestCase {
    func testAIServiceZeroLatency() async throws {
        let ai = MockAIService(latency: .zero)
        let dest = MockDataProvider.destinations[1]
        let detail = try await ai.fetchDestinationDetails(destination: dest)
        XCTAssertFalse(detail.markdown.isEmpty)
        XCTAssertFalse(detail.title.isEmpty)
    }

    func testSurpriseMeMatchesBudgetAndPetFriendly() async throws {
        let ai = MockAIService(latency: .zero)
        let request = SurpriseMeRequest(
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400*7),
            location: nil,
            budget: Decimal(2000),
            currency: .usd,
            travelers: 2,
            preferences: ["pet_friendly"]
        )
        let response = try await ai.surpriseMe(request: request)
        XCTAssertFalse(response.suggestedOption.destination.name.isEmpty)
        XCTAssertFalse(response.reasoning.isEmpty)
        // Should include alternatives
        XCTAssertFalse(response.alternatives.isEmpty)
    }

    func testMapsServiceZeroLatency() async throws {
        let maps = MockMapsService(latency: .zero)
        let pins = try await maps.getPins(for: MockDataProvider.destinations[0].id)
        XCTAssertFalse(pins.isEmpty)
        let route = try await maps.calculateRoute(from: GeoCoordinate(latitude: 0, longitude: 0), to: GeoCoordinate(latitude: 1, longitude: 1))
        XCTAssertFalse(route.pins.isEmpty)
    }

    func testAlertServiceZeroLatency() async throws {
        let alerts = MockAlertService(latency: .zero)
        let all = try await alerts.fetchAllAlerts(userId: MockDataProvider.currentUser.id)
        XCTAssertFalse(all.isEmpty)
        XCTAssertTrue(all.contains(where: { $0.type == .weather }))
        XCTAssertTrue(all.contains(where: { $0.type == .price }))
    }
}
