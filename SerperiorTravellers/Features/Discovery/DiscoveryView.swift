import SwiftUI

public struct DiscoveryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var viewModel = DiscoveryViewModel()

    public init() {}

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                // Header – Airbnb vibe, matches Good UI greeting pattern (Hello, name) + Where to?
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Where to?")
                                .typography(AppTypography.largeTitle)
                                .lineLimit(1)
                            Text("Discover stays & experiences")
                                .typography(AppTypography.subheadline, color: AppColors.textSecondary)
                        }
                        Spacer()
                        Button { appState.explorePath.append(ProfileDestination.profile) } label: {
                            Text(appState.currentUser?.initials ?? "AT")
                                .typography(AppTypography.footnoteSemibold, color: AppColors.primary)
                                .frame(width: 36, height: 36)
                                .background(AppColors.backgroundSecondary, in: Circle())
                                .overlay(Circle().stroke(AppColors.borderLight, lineWidth: 1))
                        }
                        .accessibilityIdentifier("profile_button")
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 48)

                // Search pill
                Button { appState.explorePath.append(SearchNavigationTrigger()) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Where to?")
                                .typography(AppTypography.calloutSemibold)
                            Text("Search destinations, stays, experiences")
                                .typography(AppTypography.caption1, color: AppColors.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(AppColors.backgroundSecondary, in: Circle())
                            .overlay(Circle().stroke(AppColors.borderLight, lineWidth: 1))
                    }
                    .padding(.horizontal, 14).frame(height: 56)
                    .background(AppColors.cardBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.borderLight, lineWidth: 1))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppSpacing.screenHorizontal)

                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Recommended for you", subtitle: "Handpicked escapes • \(viewModel.vacationOptions.count) options", showSeeAll: false)
                    VacationCarousel(options: viewModel.vacationOptions) { opt in
                        appState.explorePath.append(opt.destination)
                    }
                }

                SurpriseMeCard { budget in
                    Task { await viewModel.surpriseMe(budget: budget) }
                }

                HotPropertiesSection(properties: viewModel.hotProperties.isEmpty ? MockDataProvider.properties : viewModel.hotProperties, onTap: { appState.explorePath.append($0) })

                HotActivitiesSection(activities: viewModel.hotActivities.isEmpty ? MockDataProvider.activities : viewModel.hotActivities, onTap: { appState.explorePath.append($0) })

                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Trending destinations", showSeeAll: false)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(viewModel.trendingDestinations.isEmpty ? MockDataProvider.destinations : viewModel.trendingDestinations) { dest in
                            DestinationGridCard(destination: dest) { appState.explorePath.append(dest) }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                }

                Color.clear.frame(height: 90)
            }
            .padding(.top, 8)
        }
        // Background fills entire window including top safe area (fixes black bars), content respects safe area via toolbar
        .background(AppColors.background.ignoresSafeArea(edges: [.top, .horizontal]))
        // Keep nav bar hidden but avoid overlapping Dynamic Island by using safe area padding + toolbar background
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaPadding(.top, 16)
        .refreshable { await viewModel.refresh() }
        .task { viewModel.configure(with: dependencies) }
        .sheet(isPresented: $viewModel.showSurpriseSheet) {
            if let result = viewModel.surpriseMeResult {
                SurpriseMeResultView(response: result) { viewModel.showSurpriseSheet = false }.presentationDetents([.large])
            }
        }
    }
}

public struct DestinationGridCard: View {
    public let destination: Destination
    public var onTap: () -> Void
    public init(destination: Destination, onTap: @escaping () -> Void) { self.destination = destination; self.onTap = onTap }

    public var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: destination.coverImageURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(AppColors.backgroundSecondary).shimmer()
                    }
                }
                .frame(height: 140).clipped()
                LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 1) {
                    Text(destination.name).typography(AppTypography.caption1Semibold, color: .white)
                    Text(destination.country).typography(AppTypography.caption2, color: .white.opacity(0.85))
                }.padding(10)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .appShadow(.card)
        }.buttonStyle(.plain)
    }
}
