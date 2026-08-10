import SwiftUI

// MARK: - RootView – System TabView (Good UI polish) + per-tab NavigationStack (Good Structure deep-link)
// Fixes: black top/bottom scene (old Good Structure used UIView.appearance white + ZStack black window),
// floating blur tab overlapping cards (iOS 26). Good UI looks nicer because it does NOT use UIKit appearance,
// uses system background + simple TabView. We match that plus SwiftUI toolbarBackground modifiers.

public struct RootView: View {
    @EnvironmentObject var appState: AppState

    public var body: some View {
        ContentTabView()
            .tint(AppColors.primary)
            .background(AppColors.background)
            .overlay(alignment: .top) {
                if let error = appState.errorMessage {
                    Text(error)
                        .font(AppTypography.footnoteMedium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(AppColors.error, in: Capsule())
                        .padding(.top, 58)
                        .onTapGesture { appState.clearError() }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: appState.errorMessage)
    }
}

// MARK: - ContentTabView – 5 tabs, each own NavigationStack with path in AppState, toolbarBackground fixes black scene

struct ContentTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dependencies: DependencyContainer

    var body: some View {
        // System TabView – like Good UI MainTabView, not custom bar, so app.tabBars UITest queries work
        TabView(selection: $appState.selectedTab) {
            // Explore – home
            NavigationStack(path: $appState.explorePath) {
                DiscoveryView()
                    .navigationDestination(for: Destination.self) { dest in
                        DestinationDetailView(destination: dest)
                    }
                    .navigationDestination(for: Property.self) { prop in
                        PropertyDetailView(property: prop)
                    }
                    .navigationDestination(for: Activity.self) { act in
                        ActivityDetailView(activity: act)
                    }
                    .navigationDestination(for: SearchNavigationTrigger.self) { _ in
                        SearchView()
                    }
                    .navigationDestination(for: ProfileDestination.self) { dest in
                        ProfileDestinationView(dest: dest)
                    }
            }
            .toolbarBackground(AppColors.cardBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Explore", systemImage: appState.selectedTab == .explore ? "safari.fill" : "safari") }
            .tag(AppState.AppTab.explore)

            NavigationStack(path: $appState.searchPath) {
                SearchView()
            }
            .toolbarBackground(AppColors.cardBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(AppState.AppTab.search)

            NavigationStack(path: $appState.wishlistPath) {
                WishlistsView()
                    .navigationDestination(for: Wishlist.self) { wl in
                        WishlistDetailView(wishlist: wl)
                    }
            }
            .toolbarBackground(AppColors.cardBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Wishlists", systemImage: appState.selectedTab == .wishlists ? "heart.fill" : "heart") }
            .tag(AppState.AppTab.wishlists)

            NavigationStack(path: $appState.tripsPath) {
                TripsView()
                    .navigationDestination(for: Trip.self) { trip in
                        TripDetailView(trip: trip)
                    }
                    .navigationDestination(for: CollaborationNav.self) { nav in
                        CollaborationView(trip: nav.trip)
                    }
            }
            .toolbarBackground(AppColors.cardBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Trips", systemImage: appState.selectedTab == .trips ? "suitcase.fill" : "suitcase") }
            .tag(AppState.AppTab.trips)

            NavigationStack(path: $appState.mapsPath) {
                MapsView()
            }
            .toolbarBackground(AppColors.cardBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .tabItem { Label("Maps", systemImage: appState.selectedTab == .maps ? "map.fill" : "map") }
            .tag(AppState.AppTab.maps)
        }
        // Ensure TabView itself also has visible background on iOS 26 to kill floating blur pill overlapping
        .toolbarBackground(AppColors.cardBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Navigation triggers

public struct SearchNavigationTrigger: Hashable {}
public struct CollaborationNav: Hashable { let trip: Trip }
public enum ProfileDestination: Hashable {
    case bookings, alerts, ai, priceTracker, collaboration, profile
}

@ViewBuilder
public func ProfileDestinationView(dest: ProfileDestination) -> some View {
    switch dest {
    case .bookings: BookingSearchView()
    case .alerts: AlertsView()
    case .ai: AIAssistantView()
    case .priceTracker: PriceTrackerView()
    case .collaboration: CollaborationView(trip: MockDataProvider.trips.first!)
    case .profile: ProfileView()
    }
}

// MARK: - Detail Views – token-clean, adaptive, with toolbar backgrounds

public struct DestinationDetailView: View {
    public let destination: Destination
    @EnvironmentObject var dependencies: DependencyContainer

    public init(destination: Destination) { self.destination = destination }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: destination.coverImageURL) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill().frame(height: 340).clipped()
                        case .empty: Rectangle().fill(AppColors.backgroundSecondary).frame(height: 300).shimmer()
                        case .failure: Rectangle().fill(AppColors.backgroundSecondary).frame(height: 300).overlay(Image(systemName: "photo"))
                        @unknown default: Rectangle().fill(AppColors.backgroundSecondary).frame(height: 300)
                        }
                    }
                    LinearGradient(colors: [.black.opacity(0.32), .clear], startPoint: .top, endPoint: .center).frame(height: 100)
                    if destination.isTrending {
                        BadgeView(text: "Popular", style: .hot).padding(.top, 12).padding(.leading, 16)
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(destination.name).typography(AppTypography.title1).foregroundStyle(AppColors.textPrimary)
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill").font(.caption).foregroundStyle(AppColors.star)
                            Text(String(format: "%.1f • %d reviews • %@", destination.rating, destination.reviewCount, destination.country)).typography(AppTypography.caption1, color: AppColors.textSecondary)
                        }
                        Text(destination.description).typography(AppTypography.body, color: AppColors.textSecondary).lineSpacing(2).padding(.top, 2)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal).padding(.top, 16)

                    Divider().padding(.horizontal, AppSpacing.screenHorizontal).padding(.top, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Where to stay").typography(AppTypography.title3).padding(.horizontal, AppSpacing.screenHorizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(MockDataProvider.properties.filter { $0.destinationId == destination.id }) { prop in
                                    PropertyCard(property: prop).frame(width: 240)
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Things to do").typography(AppTypography.title3).padding(.horizontal, AppSpacing.screenHorizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(MockDataProvider.activities.filter { $0.destinationId == destination.id }) { act in
                                    ActivityCard(activity: act).frame(width: 210)
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    PrimaryButton(title: "Check availability") {}.padding(.horizontal, AppSpacing.screenHorizontal).padding(.vertical, 20)
                        .padding(.bottom, 90) // ensure above tab bar
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(destination.name)
        .toolbarBackground(AppColors.cardBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

public struct PropertyDetailView: View {
    public let property: Property
    public init(property: Property) { self.property = property }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                AsyncImage(url: property.coverImageURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill().frame(height: 280).clipped()
                    default: Rectangle().fill(AppColors.backgroundSecondary).frame(height: 280)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text(property.title).typography(AppTypography.title2)
                    Text("\(property.type.displayName) • \(property.maxGuests) guests").typography(AppTypography.caption1, color: AppColors.textSecondary)
                    HStack {
                        RatingView(rating: property.rating, reviewCount: property.reviewCount)
                        Spacer()
                        if property.isSuperhost { BadgeView(text: "Superhost", style: .superhost) }
                    }
                    Divider()
                    Text(property.description.isEmpty ? "Premium stay with fast Wi-Fi and local charm." : property.description).typography(AppTypography.subheadline, color: AppColors.textSecondary)
                    HStack(spacing: 8) {
                        ForEach(Array(property.amenities.prefix(4)), id: \.self) { amenity in
                            TagChip(title: amenity.displayName, icon: amenity.systemIcon)
                        }
                    }
                    PrimaryButton(title: "Reserve – \(property.currency.symbol)\(NSDecimalNumber(decimal: property.pricePerNight))/night") {}
                        .padding(.bottom, 90)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal).padding(.bottom, 20)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(property.title)
        .toolbarBackground(AppColors.cardBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

public struct ActivityDetailView: View {
    public let activity: Activity
    public init(activity: Activity) { self.activity = activity }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: activity.coverImageURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill().frame(height: 240).clipped()
                    default: Rectangle().fill(AppColors.backgroundSecondary).frame(height: 240)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 8) {
                    BadgeView(text: activity.category.displayName, style: .category)
                    Text(activity.title).typography(AppTypography.title2)
                    HStack {
                        RatingView(rating: activity.rating, reviewCount: activity.reviewCount)
                        Text("• \(activity.duration.displayString)").typography(AppTypography.caption1, color: AppColors.textSecondary)
                    }
                    Text(activity.description).typography(AppTypography.subheadline, color: AppColors.textSecondary)
                    PrimaryButton(title: "Book – \(activity.formattedPrice)") {}
                        .padding(.bottom, 90)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal).padding(.bottom, 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Experience").navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.cardBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

public struct PriceTrackerView: View {
    @EnvironmentObject var dependencies: DependencyContainer
    @State private var items: [TrackedPriceItem] = []

    public init() {}

    public var body: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView("No tracked prices", systemImage: "chart.line.downtrend.xyaxis", description: Text("Track hotels or flights to monitor price drops."))
            } else {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.type.displayName).typography(AppTypography.headlineSmall)
                        Text("Original \(item.currency.symbol)\(NSDecimalNumber(decimal: item.originalPrice)) → Now \(item.currency.symbol)\(NSDecimalNumber(decimal: item.currentPrice))").typography(AppTypography.caption1, color: AppColors.textSecondary)
                        if item.priceDropPercent > 0 {
                            BadgeView(text: String(format: "-%.0f%% drop", item.priceDropPercent), style: .success)
                        }
                    }
                }
            }
        }
        .task { if let tracker = dependencies.priceTrackerService as? MockPriceTrackerService { items = (try? await tracker.getTrackedItems()) ?? [] } }
        .navigationTitle("Price Tracker")
        .background(AppColors.background)
        .toolbarBackground(AppColors.cardBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
