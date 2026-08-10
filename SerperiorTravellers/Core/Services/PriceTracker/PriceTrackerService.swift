import Foundation

public enum PriceTrackerError: LocalizedError {
    case alreadyTracking, notFound, checkFailed(String)
    public var errorDescription: String? {
        switch self {
        case .alreadyTracking: return "Already tracking this item"
        case .notFound: return "Tracked item not found"
        case .checkFailed(let m): return "Price check failed: \(m)"
        }
    }
}

public struct PriceHistoryPoint: Codable, Sendable, Equatable {
    public var date: Date
    public var price: Decimal
    public init(date: Date, price: Decimal) { self.date = date; self.price = price }
}

public struct PriceCheckResult: Sendable, Equatable {
    public var trackedItem: TrackedPriceItem
    public var hasDropped: Bool
    public var dropPercent: Double
    public var history: [PriceHistoryPoint]
}

public protocol PriceTrackerServiceProtocol: Sendable {
    func trackPrice(type: BookingType, referenceId: UUID, currentPrice: Decimal, currency: Currency) async throws -> TrackedPriceItem
    func untrack(id: UUID) async throws
    func getTrackedItems() async throws -> [TrackedPriceItem]
    func checkPriceChanges() async throws -> [PriceCheckResult]
    func getPriceHistory(for id: UUID) async throws -> [PriceHistoryPoint]
}
