# Wishlists Feature — Save & Organize

**Owner:** @team-wishlists
**Allowed:** Core/Models Wishlist WishlistItem WishlistType, Core/Storage, Core/DesignSystem
**Forbidden:** Other Features

## Purpose
Spec 3: let users save destinations and ideas to wishlists organized by Location + Vacation type e.g., family-friendly, pet-friendly + Add/edit flow.

## Files
- WishlistsView.swift — List vs EmptyStateView no wishlists yet saves • Location/Vacation type Create wishlist button showCreate. ForEach wishlists NavigationLink value wl WishlistRow cover 64 title itemCount • type badge. onDelete deletes via VM deleteWishlist. toolbar plus + sheet AddEditWishlistView. .task configure storage.
- WishlistViewModel.swift — @Published wishlists isLoading storage? init MockDataProvider.wishlists configure storage load() loadWishlists from storage else mock, createWishlist title description type userId creates Wishlist append + save, update, delete, addItem/removeItem via mutations addItem/removeItem updating updatedAt + save.
- WishlistRow — HStack image 64 + title + itemCount + type + badge.
- WishlistDetailView wishlist: Wishlist — List Items id ForEach items icon map/bed/ticket + kind + addedAt.
- AddEditWishlistView onSave closure (title, desc?, type) -> VM createWishlist. Form fields + Picker Type AllCases + Section Organization hint about Location/Vacation type family/pet-friendly. Toolbar cancel/save disabled when title empty.

## Spec
- Organized by Location + Vacation type → WishlistType enum location/vacationType/custom + FavoriteType pet_friendly tag in Mock + seed Pet Adventures wishlist.
- Add/edit → CRUD via storage protocol-extension defaults + AddEditWishlistView sheet.

## DI
configure(storage:) from env dependencies.storageService. No second container.

## Testing
StorageServiceTests wishlistCRUD: saveWishlist -> load 1, addItem destinationItem -> count1, remove ->0, delete ->empty. ModelTests wishlistMutation, wishlistTypeOrganization, favorite pet_friendly.

## TODOs
- Implement edit title/description flow + privacy toggle isPrivate.
- Implement swipe actions add to trip or share.
- Implement grid 2-col + cover carousel.
