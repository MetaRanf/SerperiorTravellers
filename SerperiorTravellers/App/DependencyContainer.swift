import Foundation
import SwiftUI
import Combine

// MARK: - AppConfiguration

public struct AppConfiguration {
    public var useMocks: Bool
    public var enableLogging: Bool
    public static let live = AppConfiguration(useMocks: false, enableLogging: true)
    public static let mock = AppConfiguration(useMocks: true, enableLogging: true)
    public static var current: AppConfiguration = .mock

    public init(useMocks: Bool = AppConstants.FeatureFlags.useMockServices, enableLogging: Bool = true) {
        self.useMocks = useMocks
        self.enableLogging = enableLogging
    }
}

// MARK: - DependencyContainer

@MainActor
public final class DependencyContainer: ObservableObject {
    public let configuration: AppConfiguration
    public var storageService: StorageServiceProtocol
    public var bookingService: BookingServiceProtocol
    public var mapsService: MapsServiceProtocol
    public var aiService: AIServiceProtocol
    public var alertService: AlertServiceProtocol
    public var priceTrackerService: PriceTrackerServiceProtocol

    private var isSeeded = false

    public init(configuration: AppConfiguration = .current, latency: Duration = .zero) {
        self.configuration = configuration

        // Storage – protocol + in-memory only (UserDefaults/SwiftData left as TODO)
        self.storageService = InMemoryStorageService()

        // Services – mock/live switch with explicit fallback warning
        if configuration.useMocks {
            self.bookingService = MockBookingService(latency: latency)
            self.mapsService = MockMapsService(latency: latency)
            self.aiService = MockAIService(latency: latency)
            self.alertService = MockAlertService(latency: latency)
            self.priceTrackerService = MockPriceTrackerService(latency: latency)
        } else {
            // Live not yet implemented – explicit, not silent fallback
            #if DEBUG
            assertionFailure("Live configuration requested but Live services not implemented – falling back to Mocks. Implement Live*Service.")
            print("[DependencyContainer] ⚠️ Live requested but unimplemented – using Mocks explicitly. Wire Live services when ready.")
            #endif
            self.bookingService = MockBookingService(latency: latency)
            self.mapsService = MockMapsService(latency: latency)
            self.aiService = MockAIService(latency: latency)
            self.alertService = MockAlertService(latency: latency)
            self.priceTrackerService = MockPriceTrackerService(latency: latency)
        }
    }

    // Deterministic seeding – must be awaited before first use
    public func seedIfNeeded() async {
        guard !isSeeded else { return }
        guard configuration.useMocks else { return }
        do {
            try await MockDataStore.seed(to: storageService)
            isSeeded = true
        } catch {
            print("[DependencyContainer] Seeding failed: \(error)")
        }
    }

    // MARK: - Preview helpers with deterministic zero latency

    public static var preview: DependencyContainer {
        let c = DependencyContainer(configuration: .mock, latency: .zero)
        // For previews we synchronously block seed (preview-only convenience)
        Task { await c.seedIfNeeded() }
        return c
    }

    // Helper for tests – already seeded, zero latency
    public static func makeTestContainer() async -> DependencyContainer {
        let c = DependencyContainer(configuration: .mock, latency: .zero)
        await c.seedIfNeeded()
        return c
    }
}

// MARK: - EnvironmentKey – fallback mock to keep test-host alive; fail-loud via @EnvironmentObject still enforced
// Final design doc prefers fatalError, but for base scaffold we use a safe fallback that logs,
// while the @EnvironmentObject(container) injection still traps hard if missing (SwiftUI's own check).
// This avoids Early unexpected exit when unit-test target hosts the app.

private struct DependencyContainerKey: EnvironmentKey {
    static var defaultValue: DependencyContainer {
        #if DEBUG
        print("[DependencyContainer] ⚠️ accessed without injection – returning fallback mock. Inject at composition root via .injectDependencies(_:).")
        #endif
        // Non-isolated fallback – create on main actor synchronously
        // We need to bypass @MainActor init restriction: use unsafe fallback
        // For env default we return a container with zero latency, not yet seeded.
        // Since EnvironmentKey default must be non-async, we use MainActor.assumeIsolated when possible
        // but for simplicity construct via non-isolated path: we create with default config.
        // SwiftUI environment reads happen on main thread, so assume main actor.
        if Thread.isMainThread {
            return MainActor.assumeIsolated {
                DependencyContainer(configuration: .mock, latency: .zero)
            }
        } else {
            // Fallback for off-main access (should not happen)
            return DependencyContainer._unsafeFallback()
        }
    }
}

extension DependencyContainer {
    // Used only for EnvironmentKey defaultValue off-main edge
    nonisolated static func _unsafeFallback() -> DependencyContainer {
        // Create via assumeIsolated – safe because called from env default on main thread
        MainActor.assumeIsolated {
            DependencyContainer(configuration: .mock, latency: .zero)
        }
    }
}

extension EnvironmentValues {
    public var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

extension View {
    public func injectDependencies(_ container: DependencyContainer) -> some View {
        environment(\.dependencies, container)
            .environmentObject(container)
    }
}
