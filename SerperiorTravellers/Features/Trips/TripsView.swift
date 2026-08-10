import SwiftUI

public struct TripsView: View {
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var viewModel = TripsViewModel()

    public init() {}

    public var body: some View {
        Group {
            if viewModel.filteredTrips.isEmpty {
                EmptyStateView(title: "No trips yet", subtitle: "Your active vacation plans will appear here. Create a trip to start building your itinerary.", actionTitle: "Explore destinations") {}
            } else {
                List {
                    Section {
                        Picker("Filter", selection: $viewModel.filter) {
                            Text("All").tag(nil as TripStatus?)
                            ForEach(TripStatus.allCases) { status in Text(status.displayName).tag(Optional(status)) }
                        }.pickerStyle(.segmented)
                    }

                    ForEach(viewModel.filteredTrips) { trip in
                        NavigationLink(value: trip) {
                            TripRow(trip: trip)
                        }
                    }.onDelete { idxs in
                        idxs.forEach { viewModel.deleteTrip(id: viewModel.filteredTrips[$0].id) }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(AppColors.groupedBackground.ignoresSafeArea())
        .navigationTitle("My Trips")
        .navigationBarTitleDisplayMode(.large)
        .task { viewModel.configure(storage: dependencies.storageService) }
        .refreshable { await viewModel.load() }
    }
}

public struct TripRow: View {
    let trip: Trip
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(trip.title).typography(AppTypography.headline)
                Spacer()
                BadgeView(text: trip.status.displayName, style: trip.status == .planned ? .neutral : trip.status == .ongoing ? .success : .category)
            }
            Text(trip.dateRangeDisplay).typography(AppTypography.caption1, color: AppColors.textSecondary)
            if trip.progress > 0 {
                ProgressView(value: trip.progress).tint(AppColors.primary)
                Text("\(Int(trip.progress*100))% planned").typography(AppTypography.caption2, color: AppColors.textSecondary)
            }
            Text("\(trip.durationDisplay) • \(trip.destinationIds.count) destination\(trip.destinationIds.count == 1 ? "" : "s")").typography(AppTypography.caption1, color: AppColors.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

public struct TripDetailView: View {
    public let trip: Trip
    @State private var selectedTab = 0

    public init(trip: Trip) { self.trip = trip }

    public var body: some View {
        VStack(spacing: 0) {
            Picker("Trip Section", selection: $selectedTab) {
                Text("Itinerary").tag(0)
                Text("Bookings").tag(1)
                Text("Collab").tag(2)
                Text("Budget").tag(3)
            }
            .pickerStyle(.segmented)
            .padding()

            TabView(selection: $selectedTab) {
                ItineraryView(trip: trip).tag(0)
                BookingListForTrip(trip: trip).tag(1)
                CollaborationView(trip: trip).tag(2)
                TripBudgetView(trip: trip).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(AppColors.groupedBackground.ignoresSafeArea())
        .navigationTitle(trip.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

public struct ItineraryView: View {
    public let trip: Trip
    public init(trip: Trip) { self.trip = trip }

    public var body: some View {
        List {
            if trip.daysSorted.isEmpty {
                Section { Text("No itinerary yet – add days and activities to visualize your day-by-day schedule.").typography(AppTypography.subheadline, color: AppColors.textSecondary) }
            } else {
                ForEach(trip.daysSorted) { day in
                    Section {
                        ForEach(day.sortedActivities) { ta in
                            HStack {
                                VStack(alignment: .leading) {
                                    if let act = MockDataProvider.activities.first(where: { $0.id == ta.activityId }) {
                                        Text(act.title).typography(AppTypography.bodyMedium)
                                        Text(act.category.displayName).typography(AppTypography.caption1, color: AppColors.textSecondary)
                                    } else {
                                        Text(ta.activityId.uuidString.prefix(8)).typography(AppTypography.caption1)
                                    }
                                }
                                Spacer()
                                if ta.isCompleted { Image(systemName: "checkmark.circle.fill").foregroundStyle(AppColors.success) }
                            }
                        }
                    } header: {
                        VStack(alignment: .leading) {
                            Text(day.date.formatted(date: .abbreviated, time: .omitted)).font(.caption)
                            if let title = day.title { Text(title).font(.headline) }
                        }
                    }
                }
            }
        }
    }
}

public struct BookingListForTrip: View {
    public let trip: Trip
    public var body: some View {
        List {
            Section("Bookings linked to this trip") {
                if trip.bookingIds.isEmpty {
                    Text("No bookings yet. Use Booking tab to search hotels, flights, car rentals.").typography(AppTypography.caption1, color: AppColors.textSecondary)
                } else {
                    ForEach(trip.bookingIds, id: \.self) { id in Text(id.uuidString) }
                }
            }
        }
    }
}

public struct TripBudgetView: View {
    public let trip: Trip
    public var body: some View {
        List {
            Section("Budget") {
                if let budget = trip.budget {
                    LabeledContent("Budget", value: "\(trip.currency.symbol)\(NSDecimalNumber(decimal: budget))")
                    LabeledContent("Estimated", value: "\(trip.currency.symbol)\(NSDecimalNumber(decimal: trip.totalEstimatedCost))")
                    if let remaining = trip.remainingBudget {
                        LabeledContent("Remaining", value: "\(trip.currency.symbol)\(NSDecimalNumber(decimal: remaining))").foregroundStyle(remaining < 0 ? AppColors.error : AppColors.success)
                    }
                } else {
                    Text("No budget set")
                }
            }
        }
    }
}
