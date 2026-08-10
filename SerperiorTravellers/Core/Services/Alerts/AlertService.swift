import Foundation

public protocol AlertServiceProtocol: Sendable {
    func fetchWeatherAlerts(for destinationId: UUID) async throws -> [AppAlert]
    func fetchNewsAlerts(for destinationId: UUID) async throws -> [AppAlert]
    func fetchAlerts(for tripId: UUID) async throws -> [AppAlert]
    func fetchAllAlerts(userId: UUID) async throws -> [AppAlert]
    func markAsRead(alertId: UUID) async throws
    func subscribeToAlerts(destinationId: UUID) async throws
    func unsubscribeFromAlerts(destinationId: UUID) async throws
}
