# Discovery Feature — Explore / Home

**Owner:** @team-discovery
**Allowed:** Core/Models, Core/Services (AI, Booking), Core/DesignSystem, Core/Utilities
**Forbidden:** Other Features/* (e.g., don't import TripsViewModel directly; use Trip model id or BookingService protocol)

## Purpose
Home screen — Airbnb-like inspiration. Spec 1: vacation carousel swipeable, hot properties & attractions badge 🔥, activity recommendations when destination entered, Surprise Me budget.

## Files Owned
- DiscoveryView.swift — header Where to? + avatar profile_button, search pill Button appends SearchNavigationTrigger, Section Recommended for you + VacationCarousel, SurpriseMeCard budget, HotPropertiesSection, HotActivitiesSection, Trending grid DestinationGridCard 140.
- DiscoveryViewModel.swift — @MainActor @Published vacationOptions, hotProperties, hotActivities, trendingDestinations, isLoading, surpriseMeResult, showSurpriseSheet; `configure(with container: DependencyContainer)` sets aiService/bookingService/storageService; loadLocal from MockDataProvider; refresh async + surpriseMe(budget:travelers:) constructs SurpriseMeRequest + calls aiService.surpriseMe.
- Components/VacationCarousel.swift — VacationCarousel ScrollView H spacing ml + VacationCarouselCard 280 width AsyncImage shimmer trending Badge, title country from + price.
- Components/HotPropertiesSection.swift — HotPropertiesSection properties onTap onSave + SectionHeader 🔥 Hot stays + horizontal PropertyCard 240, HotActivitiesSection similarly ActivityCard.
- Components/SurpriseMeCard.swift — SurpriseMeCard budget String 1500 + onSurprise closure + UI H $ TextField numberPad + Surprise capsule button + cardBackground stroke + shadow; SurpriseMeResultView response reasoning + includes properties/activities + PrimaryButton book.

## Spec Mapping
- 1.1 carousel → VacationCarousel + vacationOptions 5 deterministic + isTrending
- 1.2 hot → HotPropertiesSection filter isTrending, Badge hot style, 🔥
- 1.3 activity recs → DestinationDetailView in RootView shows activities filter destinationId + AI recommendActivities stub
- 1.4 Surprise Me → SurpriseMeCard budget + AI surpriseMe request budget currency travelers preferences beach adventure + reasoning + alternatives

## DI
VM init no default container (fixes second-world). View .task { viewModel.configure(with: dependencies) } where dependencies from @EnvironmentObject DependencyContainer injected at root via injectDependencies. For previews: DiscoveryView().injectDependencies(.preview).environmentObject(AppState()).

## Testing
Use storage InMemory zero latency. Tests: ModelTests vacationOptions not empty, AIServiceTests surpriseMe pet_friendly matches, BookingServiceTests hot exists.

## TODOs for Engineers
- Replace loadLocal with real fetch from StorageService + BookingService with latency non-zero for demo.
- Implement filter by location for SupriseMe (request.location).
- Implement destination detail real booking CTA -> BookingSearchView with params.
- Token-clean: all colors via AppColors, fonts via AppTypography, spacing via AppSpacing, shadows via cardShadow().
