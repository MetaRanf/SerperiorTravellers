import Foundation
import SwiftUI
import Combine

@MainActor
public final class AppState: ObservableObject {
    // MARK: - User Session
    @Published public var currentUser: User? = MockDataProvider.currentUser
    @Published public var isAuthenticated: Bool = true
    @Published public var preferences: UserPreferences = .default

    // MARK: - Navigation – one path per tab (deep-link ready)
    @Published public var selectedTab: AppTab = .explore
    @Published public var explorePath = NavigationPath()
    @Published public var searchPath = NavigationPath()
    @Published public var wishlistPath = NavigationPath()
    @Published public var tripsPath = NavigationPath()
    @Published public var mapsPath = NavigationPath()
    @Published public var profilePath = NavigationPath()

    // MARK: - Search
    @Published public var searchText: String = ""
    @Published public var recentSearches: [RecentSearch] = []

    // MARK: - Data Caches (for quick UI access)
    @Published public var destinations: [Destination] = MockDataProvider.destinations
    @Published public var wishlists: [Wishlist] = MockDataProvider.wishlists
    @Published public var trips: [Trip] = MockDataProvider.trips
    @Published public var bookings: [AnyBooking] = MockDataProvider.sampleBookings
    @Published public var alerts: [AppAlert] = MockAlertService.makeMockAlerts()

    // MARK: - UI States
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var showOnboarding: Bool = false

    // MARK: - Collaboration
    @Published public var pendingInvites: [Invite] = []
    @Published public var collaborators: [User] = MockDataProvider.collaborators

    public init() {}

    // MARK: - Tab Definition – best of both: Good UI's 5-tab + Good Structure per-tab paths
    public enum AppTab: Int, CaseIterable, Identifiable, Hashable {
        case explore = 0, search = 1, wishlists = 2, trips = 3, maps = 4

        public var id: Int { rawValue }

        public var title: String {
            switch self {
            case .explore: return "Explore"
            case .search: return "Search"
            case .wishlists: return "Wishlists"
            case .trips: return "Trips"
            case .maps: return "Maps"
            }
        }

        public var icon: String {
            switch self {
            case .explore: return "magnifyingglass"
            case .search: return "magnifyingglass.circle"
            case .wishlists: return "heart"
            case .trips: return "suitcase"
            case .maps: return "map"
            }
        }

        public var selectedIcon: String {
            switch self {
            case .explore: return "magnifyingglass"
            case .search: return "magnifyingglass.circle.fill"
            case .wishlists: return "heart.fill"
            case .trips: return "suitcase.fill"
            case .maps: return "map.fill"
            }
        }

        public var accessibilityIdentifier: String { "tab_\(title.lowercased())" }
    }

    // MARK: - Actions

    public func selectTab(_ tab: AppTab) { selectedTab = tab }
    public func setError(_ message: String?) { errorMessage = message }
    public func clearError() { errorMessage = nil }

    // MARK: - Wishlist helpers

    public func isWishlisted(propertyId: UUID) -> Bool {
        wishlists.contains { $0.items.contains(where: {
            if case .property(_, let pid, _, _) = $0 { return pid == propertyId }
            return false
        })}
    }

    public func isWishlisted(activityId: UUID) -> Bool {
        wishlists.contains { $0.items.contains(where: {
            if case .activity(_, let aid, _, _) = $0 { return aid == activityId }
            return false
        })}
    }

    public func isWishlisted(destinationId: UUID) -> Bool {
        wishlists.contains { $0.items.contains(where: { $0.referencedDestinationId == destinationId }) }
    }
}
