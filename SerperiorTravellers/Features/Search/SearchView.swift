import SwiftUI

public struct SearchView: View {
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedDestination: Destination?

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            SearchField(text: $viewModel.query, placeholder: "Search destinations", showFilterButton: false, onSubmit: {
                viewModel.saveRecentSearch(query: viewModel.query)
            })

            if !viewModel.availableTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.availableTags, id: \.self) { tag in
                            TagChip(title: tag, isSelected: viewModel.selectedTags.contains(tag)) {
                                if viewModel.selectedTags.contains(tag) { viewModel.selectedTags.remove(tag) }
                                else { viewModel.selectedTags.insert(tag) }
                                Task { await viewModel.performSearch() }
                            }
                        }
                    }.padding(.horizontal, AppSpacing.screenHorizontal).padding(.vertical, 8)
                }
            }

            if viewModel.query.isEmpty && viewModel.recentSearches.isEmpty && viewModel.selectedTags.isEmpty {
                EmptyStateView(imageName: "magnifyingglass", title: "Search destinations", subtitle: "Try Bali, Kyoto, or beach. You can also filter by vacation type like family-friendly or pet-friendly.")
            } else {
                List {
                    if !viewModel.recentSearches.isEmpty && viewModel.query.isEmpty {
                        Section("Recent") {
                            ForEach(viewModel.recentSearches) { recent in
                                Button {
                                    viewModel.query = recent.query
                                } label: {
                                    Label(recent.query, systemImage: "clock")
                                }
                            }
                            Button("Clear Recents", role: .destructive) { viewModel.clearRecents() }
                        }
                    }

                    Section {
                        ForEach(viewModel.results) { dest in
                            Button {
                                selectedDestination = dest
                            } label: {
                                HStack(spacing: 12) {
                                    AsyncImage(url: dest.coverImageURL) { phase in
                                        switch phase {
                                        case .success(let img): img.resizable().scaledToFill().frame(width: 56, height: 56).clipped().clipShape(RoundedRectangle(cornerRadius: 8))
                                        default: RoundedRectangle(cornerRadius: 8).fill(AppColors.backgroundSecondary).frame(width: 56, height: 56)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(dest.name).typography(AppTypography.headlineSmall)
                                        Text(dest.locationDisplay).typography(AppTypography.caption1, color: AppColors.textSecondary)
                                        HStack(spacing: 4) {
                                            ForEach(dest.tags.prefix(3), id: \.self) { tag in TagChip(title: tag) }
                                        }
                                    }
                                    Spacer()
                                    if dest.isTrending { BadgeView(text: "🔥 Trending", style: .hot) }
                                }
                            }
                        }
                    } header: {
                        Text("\(viewModel.results.count) results")
                    }
                }
                .listStyle(.insetGrouped)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 8)
        .background(AppColors.groupedBackground.ignoresSafeArea())
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedDestination) { dest in
            DestinationDetailView(destination: dest)
        }
        .task { viewModel.configure(storage: dependencies.storageService) }
    }
}
