import Foundation
import Combine

@MainActor
public final class DiscoveryViewModel: ObservableObject {
    @Published public var vacationOptions: [VacationOption] = []
    @Published public var hotProperties: [Property] = []
    @Published public var hotActivities: [Activity] = []
    @Published public var trendingDestinations: [Destination] = []
    @Published public var isLoading: Bool = false
    @Published public var surpriseMeResult: SurpriseMeResponse? = nil
    @Published public var showSurpriseSheet: Bool = false

    private var aiService: AIServiceProtocol?
    private var bookingService: BookingServiceProtocol?
    private var storageService: StorageServiceProtocol?

    public init() {
        loadLocal()
    }

    public func configure(with container: DependencyContainer) {
        self.aiService = container.aiService
        self.bookingService = container.bookingService
        self.storageService = container.storageService
        Task { await refresh() }
    }

    public func loadLocal() {
        vacationOptions = MockDataProvider.vacationOptions
        hotProperties = MockDataProvider.properties.filter { $0.isTrending }
        hotActivities = MockDataProvider.activities.filter { $0.isHot }
        trendingDestinations = MockDataProvider.destinations.filter { $0.isTrending }
    }

    public func refresh() async {
        isLoading = true
        loadLocal()
        // Could fetch from storage
        if let storage = storageService {
            if let trips = try? await storage.loadTrips(), !trips.isEmpty {
                // Keep caches updated
            }
        }
        isLoading = false
    }

    public func surpriseMe(budget: Decimal, travelers: Int = 2) async {
        guard let aiService else { return }
        isLoading = true
        let req = SurpriseMeRequest(
            startDate: Date().addingTimeInterval(86400*14),
            endDate: Date().addingTimeInterval(86400*21),
            location: nil,
            budget: budget,
            currency: .usd,
            travelers: travelers,
            preferences: ["beach", "adventure"]
        )
        do {
            let result = try await aiService.surpriseMe(request: req)
            surpriseMeResult = result
            showSurpriseSheet = true
        } catch {
            print("SurpriseMe failed: \(error)")
        }
        isLoading = false
    }
}
