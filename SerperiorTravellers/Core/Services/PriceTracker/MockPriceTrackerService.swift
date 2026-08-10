import Foundation

public actor MockPriceTrackerService: PriceTrackerServiceProtocol {
    private var tracked: [TrackedPriceItem] = []
    private var histories: [UUID: [PriceHistoryPoint]] = [:]
    public var latency: Duration = .zero

    public init(latency: Duration = .zero, preload: Bool = true) {
        self.latency = latency
        if preload {
            let sample = TrackedPriceItem(type: .hotel, referenceId: MockDataProvider.properties[0].id, originalPrice: Decimal(350), currentPrice: Decimal(320), currency: .usd, lastChecked: Date())
            self.tracked = [sample]
            self.histories[sample.id] = [
                PriceHistoryPoint(date: Date().addingTimeInterval(-86400*5), price: Decimal(350)),
                PriceHistoryPoint(date: Date().addingTimeInterval(-86400*2), price: Decimal(330)),
                PriceHistoryPoint(date: Date(), price: Decimal(320))
            ]
        }
    }

    private func simulateLatencyIfNeeded() async {
        guard latency > .zero else { return }
        try? await Task.sleep(for: latency)
    }

    public func trackPrice(type: BookingType, referenceId: UUID, currentPrice: Decimal, currency: Currency) async throws -> TrackedPriceItem {
        await simulateLatencyIfNeeded()
        if tracked.contains(where: { $0.referenceId == referenceId }) {
            throw PriceTrackerError.alreadyTracking
        }
        let item = TrackedPriceItem(type: type, referenceId: referenceId, originalPrice: currentPrice, currentPrice: currentPrice, currency: currency)
        tracked.append(item)
        histories[item.id] = [PriceHistoryPoint(date: Date(), price: currentPrice)]
        return item
    }

    public func untrack(id: UUID) async throws {
        await simulateLatencyIfNeeded()
        guard let idx = tracked.firstIndex(where: { $0.id == id }) else { throw PriceTrackerError.notFound }
        tracked.remove(at: idx)
        histories.removeValue(forKey: id)
    }

    public func getTrackedItems() async throws -> [TrackedPriceItem] {
        await simulateLatencyIfNeeded()
        return tracked
    }

    public func checkPriceChanges() async throws -> [PriceCheckResult] {
        await simulateLatencyIfNeeded()
        return tracked.map { item in
            let drop = item.originalPrice > item.currentPrice
            let percent = item.priceDropPercent
            let history = histories[item.id] ?? []
            return PriceCheckResult(trackedItem: item, hasDropped: drop, dropPercent: percent, history: history)
        }
    }

    public func getPriceHistory(for id: UUID) async throws -> [PriceHistoryPoint] {
        await simulateLatencyIfNeeded()
        guard let h = histories[id] else { throw PriceTrackerError.notFound }
        return h
    }
}
