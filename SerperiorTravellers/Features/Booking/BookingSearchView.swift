import SwiftUI

public struct BookingSearchView: View {
    @EnvironmentObject var dependencies: DependencyContainer
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = BookingViewModel()
    @State private var showConfirmation = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Picker("Type", selection: $viewModel.searchType) {
                ForEach([BookingType.hotel, .flight, .carRental], id: \.self) { type in Text(type.displayName).tag(type) }
            }
            .pickerStyle(.segmented)
            .padding()

            SearchField(text: $viewModel.query, placeholder: "Where to? Hotels, flights, cars", showFilterButton: false, onSubmit: {
                Task { await viewModel.search() }
            })
            .padding(.horizontal)

            if viewModel.isLoading {
                ProgressView().padding()
            }

            List {
                switch viewModel.searchType {
                case .hotel:
                    Section("Hotels") {
                        ForEach(viewModel.hotels) { hotel in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hotel.name).typography(AppTypography.headlineSmall)
                                Text("\(hotel.pricePerNight.formatted) /night • \(hotel.guests) guests").typography(AppTypography.caption1, color: AppColors.textSecondary)
                                HStack {
                                    PrimaryButton(title: "Book") {
                                        Task {
                                            await viewModel.bookHotel(hotel, userId: appState.currentUser?.id ?? UUID())
                                            showConfirmation = true
                                        }
                                    }
                                    Button { viewModel.trackPrice(type: .hotel, referenceId: hotel.id, price: hotel.totalPrice.amount) } label: { Image(systemName: "chart.line.downtrend.xyaxis") }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                case .flight:
                    Section("Flights") {
                        ForEach(viewModel.flights) { flight in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(flight.airline) \(flight.flightNumber) – \(flight.fromCode)→\(flight.toCode)").typography(AppTypography.headlineSmall)
                                Text("Departs \(flight.departureAt.formatted(date: .abbreviated, time: .shortened)) • \(flight.durationMinutes) min • \(flight.cabinClass)").typography(AppTypography.caption1, color: AppColors.textSecondary)
                                Text(flight.price.formatted).typography(AppTypography.price)
                            }.padding(.vertical, 6)
                        }
                    }
                case .carRental:
                    Section("Car Rentals") {
                        ForEach(viewModel.cars) { car in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(car.company) – \(car.carModel)").typography(AppTypography.headlineSmall)
                                Text("\(car.pickupLocation) • \(car.carType)").typography(AppTypography.caption1, color: AppColors.textSecondary)
                                Text(car.price.formatted).typography(AppTypography.price)
                            }
                        }
                    }
                default:
                    EmptyStateView(title: "Coming soon", subtitle: "Activity booking search will be implemented by @team-booking")
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(AppColors.groupedBackground.ignoresSafeArea())
        .navigationTitle("Booking")
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.configure(booking: dependencies.bookingService, priceTracker: dependencies.priceTrackerService) }
        .onChange(of: viewModel.searchType) { _, _ in Task { await viewModel.search() } }
        .alert("Booking Confirmed", isPresented: $showConfirmation) {
            Button("OK") {}
        } message: {
            if let conf = viewModel.confirmation {
                Text("\(conf.confirmationCode): \(conf.message)")
            }
        }
    }
}
