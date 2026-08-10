# Search Feature — Basic Text Search

**Owner:** @team-search
**Allowed:** Core/Models (Destination, RecentSearch), Core/Storage, Core/DesignSystem
**Forbidden:** Other Features

## Purpose
Spec 2: basic text search for locations simple text-based no advanced filters v1. Foundation adds tag chips vacation type filtering including pet_friendly, recents.

## Files
- SearchView.swift — SearchField binding query placeholder Search destinations showFilterButton false onSubmit saveRecent, ScrollView H tags availableTags TagChip isSelected filter + EmptyStateView when empty + List recent Section clock button + results Section count + ForEach results Button selectedDestination + AsyncImage 56 rounded 8 + title headlineSmall + locationDisplay caption1 secondary + tags chip prefix 3 + Badge trending + navDestination item selectedDestination -> DestinationDetailView .task configure storage from dependencies.
- SearchViewModel.swift — @MainActor @Published query didSet debouncedSearch 300ms Task sleep 300_000_000 performSearch async isSearching filtering allDestinations MockDataProvider.destinations name country tags contains + selectedTags disjoint check, recentSearches [RecentSearch], selectedTags Set<String>, storage? configure loads recents, saveRecent deduplication lowercased max20 insert0, clearRecents, availableTags sorted set from all destinations flatMap tags.

## Spec
- 2 text search → query filtering name/country/tags, case insensitive.
- Tags organization → WishlistType + FavoriteType pet_friendly included.
- Recent → StorageService saveRecentSearch loadRecentSearches clear.

## DI
configure(storage:) from @EnvironmentObject dependencies storageService. No default container. For unit test storage isolated InMemory.

## Testing
StorageServiceTests testRecentSearchDeduplication lowercased Kyoto/kyoto ->1, ModelTests.

## TODOs
- Wire real Geocoding via MapsService geocode(address:) for query not matching local.
- Add history limit UI 20 + clear button.
- Add debounced network search when live API ready.
