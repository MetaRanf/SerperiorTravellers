import SwiftUI

public struct CollaborationView: View {
    public let trip: Trip
    @State private var inviteEmail = ""
    @State private var selectedRole: TripMemberRole = .viewer
    @State private var showShareSheet = false

    public init(trip: Trip) { self.trip = trip }

    private var tripURL: URL {
        URL(string: "https://serperior.travel/trip/\(trip.id.uuidString)")!
    }

    public var body: some View {
        List {
            Section("Trip") {
                LabeledContent("Title", value: trip.title)
                LabeledContent("Shared", value: trip.isShared ? "Yes" : "No")
                LabeledContent("Dates", value: trip.dateRangeDisplay)
            }

            Section("Members") {
                ForEach(MockDataProvider.collaborators) { user in
                    HStack {
                        Text(user.initials).font(.caption).frame(width: 32, height: 32).background(AppColors.backgroundSecondary, in: Circle())
                        VStack(alignment: .leading) {
                            Text(user.name).typography(AppTypography.bodyMedium)
                            Text(user.email).typography(AppTypography.caption1, color: AppColors.textSecondary)
                        }
                        Spacer()
                        BadgeView(text: "Editor", style: .category)
                    }
                }
            }

            Section("Invite family or friends") {
                TextField("Email", text: $inviteEmail).keyboardType(.emailAddress).autocapitalization(.none)
                Picker("Role", selection: $selectedRole) {
                    ForEach(TripMemberRole.allCases) { role in Text(role.displayName).tag(role) }
                }
                PrimaryButton(title: "Send invite") {
                    // TODO: call invite service via DependencyContainer
                }
            }

            Section("Share vacation plan") {
                PrimaryButton(title: "Generate share link", style: .secondary, icon: "link") {
                    showShareSheet = true
                }
                // System share sheet using SwiftUI.ShareLink view (explicit namespace avoids model collision)
                SwiftUI.ShareLink(item: tripURL, subject: Text("Join my trip: \(trip.title)"), message: Text("Check out my vacation plan for \(trip.title) – \(trip.dateRangeDisplay)")) {
                    Label("Share plan via system sheet", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Collaboration")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.groupedBackground.ignoresSafeArea())
        .sheet(isPresented: $showShareSheet) {
            VStack(spacing: 12) {
                Image(systemName: "link.circle.fill").font(.system(size: 48)).foregroundStyle(AppColors.primary)
                Text("Share Link").typography(AppTypography.title2)
                Text(tripURL.absoluteString).typography(AppTypography.caption1, color: AppColors.textSecondary).textSelection(.enabled)
                PrimaryButton(title: "Copy link") { UIPasteboard.general.string = tripURL.absoluteString }
                    .padding()
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}
