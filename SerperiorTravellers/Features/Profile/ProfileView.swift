import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dependencies: DependencyContainer
    @State private var pathTrigger: ProfileDestination?

    public init() {}

    public var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Text(appState.currentUser?.initials ?? "AT").typography(AppTypography.title2, color: .white).frame(width: 60, height: 60).background(AppColors.primaryGradient, in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.currentUser?.name ?? "Alex Traveller").typography(AppTypography.title3)
                        Text(appState.currentUser?.email ?? "alex@serperior.app").typography(AppTypography.caption1, color: AppColors.textSecondary)
                        if let user = appState.currentUser, user.isPremium {
                            BadgeView(text: "Premium", style: .newBadge)
                        }
                    }
                    Spacer()
                }.padding(.vertical, 8)
            }

            Section("Plan") {
                NavigationLink(value: ProfileDestination.bookings) { Label("My Bookings", systemImage: "ticket") }
                NavigationLink(value: ProfileDestination.priceTracker) { Label("Price Tracker", systemImage: "chart.line.downtrend.xyaxis") }
                NavigationLink(value: ProfileDestination.collaboration) { Label("Collaboration", systemImage: "person.2") }
            }

            Section("Assistant & Alerts") {
                NavigationLink(value: ProfileDestination.ai) { Label("AI Assistant", systemImage: "sparkles") }
                NavigationLink(value: ProfileDestination.alerts) { Label("Weather & News Alerts", systemImage: "cloud.bolt") }
            }

            Section("Preferences") {
                Picker("Currency", selection: $appState.preferences.currency) {
                    ForEach(Currency.allCases) { c in Text("\(c.symbol) \(c.displayName)").tag(c) }
                }
                Toggle("Notifications", isOn: $appState.preferences.isNotificationEnabled)
                Toggle("Price Alerts", isOn: $appState.preferences.priceAlertsEnabled)
            }

            Section("About") {
                LabeledContent("Version", value: AppConstants.appVersion)
                LabeledContent("App", value: AppConstants.appName)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
        .background(AppColors.groupedBackground.ignoresSafeArea())
    }
}
