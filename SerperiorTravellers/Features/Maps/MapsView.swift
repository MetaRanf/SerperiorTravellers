import SwiftUI
import MapKit

public struct MapsView: View {
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var viewModel = MapsViewModel()
    @State private var selectedTrip: Trip? = MockDataProvider.trips.first

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Picker("Destination", selection: $viewModel.selectedDestinationId) {
                ForEach(MockDataProvider.destinations) { dest in Text(dest.name).tag(Optional(dest.id)) }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)

            Map {
                ForEach(viewModel.pins) { pin in
                    Annotation(pin.title, coordinate: pin.coordinate.clCoordinate) {
                        VStack(spacing: 2) {
                            Image(systemName: pin.type == .activity ? "ticket.fill" : pin.type == .property ? "bed.double.fill" : "mappin.circle.fill")
                                .foregroundStyle(pin.type == .activity ? AppColors.accent : AppColors.primary)
                                .font(.title3)
                                .background(.white, in: Circle())
                            Text(pin.title).font(.caption2).padding(2).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                if let route = viewModel.route {
                    MapPolyline(coordinates: route.polyline.map(\.clCoordinate))
                        .stroke(AppColors.primary, lineWidth: 4)
                }
            }
            .mapStyle(.standard)
            .frame(maxHeight: .infinity)

            if let route = viewModel.route {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Suggested route").typography(AppTypography.headlineSmall)
                    Text("\(route.pins.count) stops • \(route.formattedDistance) • ~\(route.estimatedDurationMinutes) min")
                        .typography(AppTypography.caption1, color: AppColors.textSecondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(route.pins) { pin in TagChip(title: pin.title) }
                        }
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Maps & Routing")
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.configure(service: dependencies.mapsService) }
        .onChange(of: viewModel.selectedDestinationId) { _, _ in Task { await viewModel.loadPins() } }
    }
}
