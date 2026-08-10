import Foundation

public actor MockAlertService: AlertServiceProtocol {
    private var alerts: [AppAlert] = []
    public var latency: Duration = .zero

    public init(latency: Duration = .zero) {
        self.latency = latency
        self.alerts = Self.makeMockAlerts()
    }

    private func simulateLatencyIfNeeded() async {
        guard latency > .zero else { return }
        try? await Task.sleep(for: latency)
    }

    public func fetchWeatherAlerts(for destinationId: UUID) async throws -> [AppAlert] {
        await simulateLatencyIfNeeded()
        return alerts.filter { $0.type == .weather && $0.destinationId == destinationId }
    }

    public func fetchNewsAlerts(for destinationId: UUID) async throws -> [AppAlert] {
        await simulateLatencyIfNeeded()
        return alerts.filter { $0.type == .news && $0.destinationId == destinationId }
    }

    public func fetchAlerts(for tripId: UUID) async throws -> [AppAlert] {
        await simulateLatencyIfNeeded()
        return alerts.filter { $0.tripId == tripId || $0.destinationId == nil }
    }

    public func fetchAllAlerts(userId: UUID) async throws -> [AppAlert] {
        await simulateLatencyIfNeeded()
        return alerts.sorted { $0.timestamp > $1.timestamp }
    }

    public func markAsRead(alertId: UUID) async throws {
        await simulateLatencyIfNeeded()
        if let idx = alerts.firstIndex(where: { $0.id == alertId }) {
            alerts[idx].isRead = true
        }
    }

    public func subscribeToAlerts(destinationId: UUID) async throws {
        await simulateLatencyIfNeeded()
    }

    public func unsubscribeFromAlerts(destinationId: UUID) async throws {
        await simulateLatencyIfNeeded()
    }

    public static func makeMockAlerts() -> [AppAlert] {
        let now = Date()
        let bali = MockDataProvider.destinations[0].id
        let kyoto = MockDataProvider.destinations[1].id
        let trip = MockDataProvider.trips[0].id
        return [
            AppAlert(title: "Heavy rain in Bali", message: "Thunderstorm warning for Ubud area until tomorrow 18:00.", type: .weather, severity: .high, timestamp: now, destinationId: bali, isRead: false),
            AppAlert(title: "Cherry blossom peak", message: "Kyoto sakura expected to peak next week – perfect timing!", type: .news, severity: .low, timestamp: now.addingTimeInterval(-3600), destinationId: kyoto, isRead: false),
            AppAlert(title: "Check-in reminder", message: "Your ryokan check-in is at 15:00 tomorrow. Early check-in available.", type: .booking, severity: .medium, timestamp: now.addingTimeInterval(-7200), tripId: trip, isRead: true),
            AppAlert(title: "Price dropped 12% for Park Hyatt", message: "Good news! Park Hyatt Kyoto dropped from $920 to $810 per night.", type: .price, severity: .low, timestamp: now.addingTimeInterval(-10800), destinationId: kyoto, isRead: false)
        ]
    }
}
