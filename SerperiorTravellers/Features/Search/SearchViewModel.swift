import Foundation
import Combine

@MainActor
public final class SearchViewModel: ObservableObject {
    @Published public var query: String = "" {
        didSet { debouncedSearch() }
    }
    @Published public var results: [Destination] = []
    @Published public var recentSearches: [RecentSearch] = []
    @Published public var isSearching: Bool = false
    @Published public var selectedTags: Set<String> = []

    private var storage: StorageServiceProtocol?
    private var allDestinations: [Destination] = MockDataProvider.destinations

    private var debounceTask: Task<Void, Never>?

    public init() {
        results = MockDataProvider.destinations
    }

    public func configure(storage: StorageServiceProtocol) {
        self.storage = storage
        Task { await loadRecents() }
    }

    private func debouncedSearch() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await performSearch()
        }
    }

    public func performSearch() async {
        isSearching = true
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty && selectedTags.isEmpty {
            results = allDestinations
        } else {
            results = allDestinations.filter { dest in
                let matchesQuery = q.isEmpty || dest.name.localizedCaseInsensitiveContains(q) || dest.country.localizedCaseInsensitiveContains(q) || dest.tags.contains(where: { $0.localizedCaseInsensitiveContains(q) })
                let matchesTags = selectedTags.isEmpty || !Set(dest.tags).isDisjoint(with: selectedTags)
                return matchesQuery && matchesTags
            }
        }
        isSearching = false
    }

    public func saveRecentSearch(query: String) {
        guard !query.isEmpty else { return }
        let search = RecentSearch(query: query, type: .destination)
        Task { try? await storage?.saveRecentSearch(search); await loadRecents() }
    }

    public func loadRecents() async {
        guard let storage else { return }
        recentSearches = (try? await storage.loadRecentSearches()) ?? []
    }

    public func clearRecents() {
        Task { try? await storage?.clearRecentSearches(); await loadRecents() }
    }

    public var availableTags: [String] {
        Array(Set(allDestinations.flatMap(\.tags))).sorted()
    }
}
