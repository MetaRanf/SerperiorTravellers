import SwiftUI

public struct AlertsView: View {
    @EnvironmentObject var dependencies: DependencyContainer
    @State private var alerts: [AppAlert] = []
    @State private var filter: AlertType? = nil

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    TagChip(title: "All", isSelected: filter == nil) { filter = nil }
                    ForEach(AlertType.allCases, id: \.self) { type in
                        TagChip(title: type.displayName, icon: type.systemIcon, isSelected: filter == type) { filter = type }
                    }
                }.padding()
            }

            List {
                ForEach(filtered) { alert in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: alert.type.systemIcon).foregroundStyle(severityColor(alert.severity))
                            Text(alert.title).typography(AppTypography.headlineSmall)
                            Spacer()
                            if !alert.isRead { Circle().fill(AppColors.primary).frame(width: 8, height: 8) }
                        }
                        Text(alert.message).typography(AppTypography.subheadline, color: AppColors.textSecondary)
                        Text(alert.timestamp.formatted(date: .abbreviated, time: .shortened)).typography(AppTypography.caption2, color: AppColors.textTertiary)
                    }
                    .padding(.vertical, 4)
                    .swipeActions {
                        Button("Read") { markRead(alert) }.tint(.blue)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(AppColors.groupedBackground.ignoresSafeArea())
        .navigationTitle("Alerts")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var filtered: [AppAlert] {
        guard let filter else { return alerts }
        return alerts.filter { $0.type == filter }
    }

    private func load() async {
        guard let service = dependencies.alertService as? MockAlertService else { return }
        alerts = (try? await service.fetchAllAlerts(userId: MockDataProvider.currentUser.id)) ?? []
    }

    private func markRead(_ alert: AppAlert) {
        Task { try? await dependencies.alertService.markAsRead(alertId: alert.id); await load() }
    }

    private func severityColor(_ severity: AlertSeverity) -> Color {
        switch severity {
        case .info: return AppColors.info
        case .low: return AppColors.success
        case .medium: return AppColors.warning
        case .high: return Color.orange
        case .critical: return AppColors.error
        }
    }
}
