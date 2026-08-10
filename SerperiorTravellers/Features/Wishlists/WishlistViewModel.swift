import Foundation

@MainActor
public final class WishlistViewModel: ObservableObject {
    @Published public var wishlists: [Wishlist] = []
    @Published public var isLoading = false
    private var storage: StorageServiceProtocol?

    public init() { wishlists = MockDataProvider.wishlists }

    public func configure(storage: StorageServiceProtocol) {
        self.storage = storage
        Task { await load() }
    }

    public func load() async {
        isLoading = true
        if let storage { wishlists = (try? await storage.loadWishlists()) ?? MockDataProvider.wishlists }
        isLoading = false
    }

    public func createWishlist(title: String, description: String?, type: WishlistType, userId: UUID) {
        let wl = Wishlist(userId: userId, title: title, description: description, type: type)
        wishlists.append(wl)
        Task { try? await storage?.saveWishlist(wl) }
    }

    public func updateWishlist(_ wishlist: Wishlist) {
        if let idx = wishlists.firstIndex(where: { $0.id == wishlist.id }) {
            wishlists[idx] = wishlist
            Task { try? await storage?.saveWishlist(wishlist) }
        }
    }

    public func deleteWishlist(id: UUID) {
        wishlists.removeAll { $0.id == id }
        Task { try? await storage?.deleteWishlist(id: id) }
    }

    public func addItem(to wishlistId: UUID, item: WishlistItem) {
        if let idx = wishlists.firstIndex(where: { $0.id == wishlistId }) {
            wishlists[idx].addItem(item)
            let updated = wishlists[idx]
            Task { try? await storage?.saveWishlist(updated) }
        }
    }

    public func removeItem(wishlistId: UUID, itemId: UUID) {
        if let idx = wishlists.firstIndex(where: { $0.id == wishlistId }) {
            wishlists[idx].removeItem(id: itemId)
            let updated = wishlists[idx]
            Task { try? await storage?.saveWishlist(updated) }
        }
    }
}
