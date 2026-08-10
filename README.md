# Serperior Travellers — iOS Vacation Planning (iPhone-only)

> **Airbnb-inspired vacation planning app. Swift + SwiftUI, iOS 17+, Xcode 16+ (objectVersion 77).**
> Built from the product spec in this repo (`Spec.md`). Focus is a clean, polished foundation that many engineers can extend in parallel.

## Table of Contents

1. Product Overview & Scope
2. Quick Start
3. Build & Test (Headless CI, Simulator Picker)
4. Screenshots & Visual Verification
5. Project Structure & File Ownership
6. Spec Coverage — Foundation Roadmap
7. Architecture Summary
8. Scene & Window Configuration (Black Bars Fix)
9. Design System (Airbnb-like)
10. Core Domain Models
11. Storage Layer
12. Service / API Layer Stubs
13. Navigation Skeleton
14. Feature Vertical Slices
15. Mock Data
16. Testing
17. Engineering Conventions
18. Adding New File / Feature / Model / Service
19. Troubleshooting FAQ
20. Future Roadmap

## 1. Product Overview & Scope

Serperior Travellers helps users discover destinations via a swipeable carousel with Trending badges, view hot stays and experiences, get activity recommendations for a selected destination, use Surprise Me to get a best vacation from period/location/budget, search locations with basic text search, save wishlists organized by Location and Vacation type (family-friendly, pet-friendly) with add/edit flows, search and book travel (hotels, flights, car rentals) with price tracker and booking notifications (confirmation, check-in, departure), view a location map with user location and destination pins and suggested routes connecting activities, manage My Trips with a calendar/itinerary view day-by-day, invite family/friends to shared trips and share vacation plans via link, get richer details on flights/bookings/activities on demand via AI assistant, and receive weather/news/price alerts, plus a storage layer for users/preferences/wishlists/trips/bookings.

**First deliverable = foundation/scaffolding only** per `Spec.md`:

- Clean project structure and architecture (features / models / services / views) scaling to many contributors
- Navigation skeleton wiring main screens even if placeholders
- Core data models and storage layer interface
- Service/API stubs with mocks and clear boundaries
- Shared design system primitives (colors, typography, cards)
- Clear module boundaries and conventions for parallel team work

The feature list is the product roadmap the foundation supports.

## 2. Quick Start

**Requirements**
- Xcode 16+ (`objectVersion = 77`, verified Xcode 26.6 17F113). Xcode 15 cannot open this project.
- `brew install xcodegen` — generates `SerperiorTravellers.xcodeproj` from `project.yml`
- iPhone simulator iOS 17+ (iPhone 15/16/Pro). Use `scripts/pick-simulator.sh` to pick UDID reproducibly.

**Open**
```bash
cd /Users/ranf/AAI/Serperior-Travellers/SerperiorTravellers
open SerperiorTravellers.xcodeproj
# Scheme: SerperiorTravellers, iPhone only, Bundle com.serperiortravellers.app, iOS 17, Swift 5, no third-party deps
```
If signing error: add `CODE_SIGNING_ALLOWED=NO` to xcodebuild or set your team in Signing & Capabilities.

Run `Cmd+R` — tabs: Explore, Search, Wishlists, Trips, Maps. Profile hub secondary via avatar.

## 3. Build & Test (Headless CI, Simulator Picker)

**Assets valid**: `Assets.xcassets` contains valid `Contents.json` for root, `AppIcon.appiconset` universal 1024, `AccentColor.colorset` adaptive teal #00A699 light (0,0.651,0.6) dark (0.2,0.75,0.7), `Placeholder.imageset` 1x/2x/3x — `actool` zero warnings.

**Generic build (no concrete simulator, build only)**
```bash
xcodebuild -project SerperiorTravellers.xcodeproj -scheme SerperiorTravellers -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/st-dd CODE_SIGNING_ALLOWED=NO build # BUILD SUCCEEDED
```
`generic/platform=iOS Simulator` is valid for build only.

**Concrete test (requires booted iPhone)**
```bash
UDID=$(scripts/pick-simulator.sh)  # prints UDID or exits 1 with instructions to create simulator
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl ui "$UDID" appearance light   # light looks nicer for Airbnb vibe
xcodebuild -project SerperiorTravellers.xcodeproj -scheme SerperiorTravellers -destination "id=$UDID" -derivedDataPath /tmp/st-dd CODE_SIGNING_ALLOWED=NO test  # 26 unit + 3 UI = 29 green
```

**Single case**
```bash
xcodebuild ... test -only-testing:SerperiorTravellersTests/ModelTests
xcodebuild ... test -only-testing:SerperiorTravellersTests/StorageServiceTests/testSaveLoadRoundTrip
xcodebuild ... test -skip-testing:SerperiorTravellersUITests
```

**Shared scheme**: at `SerperiorTravellers.xcodeproj/xcshareddata/xcschemes/SerperiorTravellers.xcscheme` checked in, Test action wired to both unit and UI test bundles. `.gitignore` excludes `build/`, `DerivedData/`, `xcuserdata/`, `*.xcuserstate`, `.DS_Store`, `*.xcodegen.cache` but explicitly keeps `xcshareddata/` via `!**/xcshareddata/**`.

## 4. Screenshots & Visual Verification

`simctl io screenshot` default `--mask=black` renders display mask (rounded corners + Dynamic Island) as black, and captures App Switcher if app backgrounded (double status bar — outer white on black + inner gray). Use:

```bash
xcrun simctl io "$UDID" screenshot --mask=ignored /tmp/clean.png   # rectangular framebuffer
xcrun simctl io "$UDID" screenshot --mask=alpha /tmp/alpha.png
```

**Launch foreground**
```bash
xcrun simctl terminate "$UDID" com.serperiortravellers.app || true
xcrun simctl install "$UDID" /tmp/st-dd/Build/Products/Debug-iphonesimulator/SerperiorTravellers.app
xcrun simctl launch "$UDID" com.serperiortravellers.app
sleep 3
xcrun simctl io "$UDID" screenshot --mask=ignored /tmp/app.png
```

Current polished build: white edge-to-edge, black time (light scheme), Dynamic Island above "Where to?" not overlapping (header top 48 + safeAreaPadding 16), search pill with magnifying/filter icons, Recommended carousel Bali Indonesia from $1800 Trending 4.8 5 nights + Kyoto, Surprise Me card budget $1500 pink button, Hot stays section, bottom opaque white tab bar Explore red selected Search/Wishlists/Trips/Maps gray, home indicator gray — no black bars, no floating blur pill overlapping cards.

## 5. Project Structure & File Ownership

```
project.yml — xcodegen spec, bundleIdPrefix com.serperiortravellers, iOS 17, xcodeVersion 16.0, generateEmptyDirectories, SWIFT_VERSION 5.0, TARGETED_DEVICE_FAMILY 1, Info.plist via SerperiorTravellers/Resources/Info.plist, MARKETING_VERSION 1.0.0, CODE_SIGNING_ALLOWED NO, schemes build/run/test/archive

SerperiorTravellers.xcodeproj/ — generated, objectVersion 77, xcshareddata/xcschemes/SerperiorTravellers.xcscheme checked in

SerperiorTravellers/
  App/
    SerperiorTravellersApp.swift — @main, StateObject dependencies (mock latency zero) + appState, init AppAppearance.configure paints UIWindow white, WindowGroup RootView envObject appState+dependencies env dependencies tint primary background white/systemBackground ignoresSafeArea preferredColorScheme .light + task seedIfNeeded + onAppear paints windowScene windows white override light (kills black top/bottom)
    RootView.swift — RootView + ContentTabView system TabView 5 tabs each NavigationStack path per-tab NavigationPath deep-link future, each NavigationStack toolbarBackground cardBackground for tabBar .visible + TabView itself same (fixes floating blur pill), tabItem Label Explore/Search/Wishlists/Trips/Maps safari/magnifyingglass/heart/suitcase/map + tag, navigation triggers SearchNavigationTrigger/CollaborationNav + ProfileDestination enum bookings/alerts/ai/priceTracker/collaboration/profile + ProfileDestinationView hub switch. Detail views (DestinationDetailView cover 340 Popular badge flame.fill SF Symbol, stays horizontal PropertyCard 240, experiences ActivityCard 210, PrimaryButton Check availability padding bottom 90; PropertyDetailView 280 rounded; ActivityDetailView; PriceTrackerView List)
    AppState.swift — @MainActor ObservableObject, currentUser MockDataProvider.currentUser, isAuthenticated, preferences default, selectedTab AppTab 5 cases explore/search/wishlists/trips/maps Int raw title icon selectedIcon accessibility tab_*, explorePath/searchPath/wishlistPath/tripsPath/mapsPath/profilePath NavigationPath, searchText recentSearches, caches destinations/wishlists/trips/bookings/alerts/collaborators isLoading errorMessage showOnboarding pendingInvites, actions selectTab setError clearError isWishlisted helpers.
    DependencyContainer.swift — @MainActor composition root, configuration AppConfiguration useMocks enableLogging static live/mock/current, storage Booking/maps/AI/alert/priceTracker services, isSeeded, init useMocks true mocks latency param else assertionFailure DEBUG explicit warning fallback mocks (not silent), seedIfNeeded async await MockDataStore.seed, preview + makeTestContainer zero latency, EnvironmentKey fallback safe mock logging warning not fatal (prevents early exit when unit-test host app launches), _unsafeFallback nonisolated via assumeIsolated for nonisolated defaultValue, injectDependencies extension View environment.

  Core/
    Models/ 11 files single source truth UUID Identifiable Codable Equatable Hashable Sendable — see §10
    Storage/ StorageService.swift (StorageError, StorageKey namespace com.serperior.storage.*, StorageServiceProtocol 5 primitives async throws + domain helpers as extension defaults, RecentSearch, TrackedPriceItem), InMemoryStorageService actor [String:Data] JSON iso8601 sortedKeys + seedSync synchronous, MockDataStore enum async seed fast path mem seedSync else generic + makeSeededMemoryStorageSync semaphore blocking previews
    Services/ 5 domains AI/Alerts/Booking/Maps/PriceTracker each protocol Sendable async throws + error enum + DTOs + actor Mock latency Duration.zero
    DesignSystem/ Colors.swift Color(hex:) adaptive light/dark via UIColor trait AppColors coral #FF385C teal #00A699 semantic backgrounds/text/borders/shadows badges + Typography.swift AppFont rounded design + AppTypography scale largeTitle 34 bold title1 28 title2 22 title3 20 headline 17 body 17 callout 16 subheadline 15 footnote 13 caption 11 price badge overline + .typography() modifier, Spacing.swift AppSpacing 4pt scale xxs-xxl + semantic cardPadding screenHorizontal 24 + CornerRadius xs-full semantic card 16 large 24 button 12 + Shadow + AppLayout + View modifiers cardShadow appShadow, Theme.swift AppTheme light/dark/current colorScheme isDark + ThemeKey env + ThemedBackground CardBackgroundModifier ThemedCardModifier appThemedBackground themedCard cardBackground appTheme + AppAppearance enum configure UIWindow white + TabBar opaque white isTranslucent false shadow + ThemePreviewContainer, Components/ RoundedCard generic, PropertyCard (200 height image trending badge wishlist heart rating price), ActivityCard HOT badge, BadgeView styles hot/trending/superhost/category/neutral/success/warning/price/new + flame.fill for hot, PrimaryButton primary/secondary/outline/ghost/destructive sizes small/medium/large/extraLarge isEnabled alias IconButton GradientButton, SearchField airbnbBar pill capsule magnifying placeholder clear x filter slider 30 circle stroke shadow, SectionHeader title subtitle SeeAll, CarouselView generic TabView page indicators, ShimmerView + skeletons, EmptyStateView, TagChip selectable pill icon, RatingView star rating count, PriceLabel Money amount suffix.

    Utilities/ Constants.swift AppConstants appName bundleId appVersion supportEmail FeatureFlags useMockServices enableAIAssistant etc APIKeys amadeus bookingCom openWeather mapBox empty UI constants Pagination Defaults cacheExpiration, Extensions Color+Extensions random lighter/darker uiColor + View+Extensions airbnb shadows hideKeyboard cornerRadius placeholder shimmer haptic, MockData MockDataProvider deterministic.

  Features/ 10 vertical slices each View+VM+README — see §14
  Resources/ Assets.xcassets valid + Info.plist with UILaunchScreen{UILaunchScreen:{}} + UISupportedInterfaceOrientations portrait + UIApplicationSceneManifest SupportsMultipleScenes true UISceneConfigurations {} + UIDeviceFamily 1 iPhone-only + NSLocationWhenInUse + NSAccentColorName + CFBundleDisplayName excluding README.md via project.yml

SerperiorTravellersTests/ ModelTests, StorageServiceTests, BookingServiceTests, AIServiceTests — 26 tests zero-latency deterministic
SerperiorTravellersUITests/ AppLaunchTests, NavigationTests — 3 tests tabBars 5 tabs reachable default Explore
scripts/pick-simulator.sh hardened picker
Spec.md — product spec source of truth (copied into repo)
README.md ARCHITECTURE.md .gitignore
```

**File ownership for parallel team** (suggested):

- Discovery: Features/Discovery + VacationOption
- Search: Features/Search + RecentSearch
- Wishlists: Features/Wishlists + Wishlist
- Trips: Features/Trips + Trip
- Maps: Features/Maps + MapsService + GeoCoordinate
- Booking: Features/Booking + BookingService + PriceTracker
- Collaboration: Features/Collaboration + Collaboration model
- AI: Features/AI + AIService
- Alerts: Features/Alerts + AlertService
- DesignSystem: Core/DesignSystem
- Storage/Data: Core/Storage + MockDataProvider

## 6. Spec Coverage — Foundation Roadmap

| Feature | Foundation |
|---|---|
| Vacation carousel scrollable | VacationCarousel 280 width Popular badge flame, 5 deterministic options |
| Hot properties/attractions badge | isTrending/isHot filter, BadgeView hot/trending, SectionHeader 🔥 |
| Activity recs when destination entered | DestinationDetailView filters activities by destinationId, AI recommend stub |
| Surprise Me period/location/budget best | SurpriseMeCard budget + SurpriseMeRequest start/end/budget/travelers/preferences + MockAIService filters budget/tags reasoning alternatives |
| Basic text search locations | SearchView debounced 300ms filters name/country/tags, tag chips incl pet_friendly, recents via storage |
| Wishlists by Location/Vacation type family pet-friendly | WishlistType location/vacationType/custom + FavoriteType beach..petFriendly, seed Pet Adventures |
| Add/edit wishlist flow | WishlistViewModel CRUD + AddEditWishlistView sheet |
| Booking APIs hotels/flights/cars search+booking | BookingServiceProtocol + DTOs HotelSearchParams/FlightSearchParams/CarRentalSearchParams/BookingConfirmation + MockBookingService actor |
| Price tracker generic | PriceTrackerServiceProtocol + TrackedPriceItem + PriceTrackerView |
| Booking notifications | BookingAlert + AppAlert via MockAlertService check-in reminder price drop |
| Location map user+destinations | MapsView Map Annotation + MapPolyline + NSLocationWhenInUse |
| Pins + suggested route | MapPin PinType + SuggestedRoute polyline [GeoCoordinate] distance formatted |
| My Trips active plans | TripsView filter TripStatus sorted |
| Calendar itinerary day-by-day | TripDetailView segmented Itinerary/Bookings/Collab/Budget ItineraryView TripDay sorted activities + completion |
| Invite family/friends shared trip | Invite + TripMember Role Permission, CollaborationView email+role |
| Share vacation plan | TripShareLink model + SwiftUI.ShareLink system sheet item URL + copy |
| AI richer details | AIService fetchFlight/Booking/Activity/Destination AIDetailResponse markdown highlights + AIAssistantView chat bubbles |
| Weather & news alerts | AlertService weather/news for destination, WeatherAlert NewsAlert severity colors |
| Storage users/prefs/wishes | StorageServiceProtocol 5 primitives + domain helpers, InMemory actor deterministic seeded awaited |

## 7. Architecture Summary

MVVM + protocol-oriented services + DI composition root via @EnvironmentObject + per-tab NavigationStack. Single module convention-enforced, objectVersion 77 via xcodegen scripted deterministic, filesystem sync groups future recommendation.

App composes DI + AppState once, injects via environment, seeds awaited before first UI. Core single source of truth models. Storage 5 primitives + helpers defaults actor. Services protocol + mock actor zero latency. Design system tokens enforce Airbnb style. Features vertical slices View+VM+README depend only Core.

## 8. Scene & Window Configuration (Black Bars Fix)

Black bars reported top (status bar area black white time) + bottom (home indicator area black below tab bar) caused by:

- Info.plist missing `UILaunchScreen` → launch background black persists after appearance
- `UIDeviceFamily` universal [1,2] → iPad letterboxing
- `NavigationStack` hidden toolbar leaves top safe area showing window black; background not ignoring safe area
- Root `TabView` background not ignoring safe area; window black visible
- `simctl io screenshot --mask=black` default renders display mask (rounded corners + Dynamic Island) as black

Fix matching clean light UI:

- Info.plist custom at `Resources/Info.plist`: `UILaunchScreen:{UILaunchScreen:{}}` empty dict white launch, `UIDeviceFamily [1]` iPhone-only, portrait only, `UIApplicationSceneManifest` multiple scenes empty, `NSLocationWhenInUse`, `NSAccentColorName`. `project.yml` uses `info.path` + `properties` + target `INFOPLIST_FILE` = Resources/Info.plist + `GENERATE_INFOPLIST_FILE NO` for target.

- Window: `UIWindow.appearance().backgroundColor = .white` only (not UIView globally which blanked images/search pill). Additionally in App `onAppear` paints `windowScene.windows.forEach { $0.backgroundColor=.white; $0.overrideUserInterfaceStyle=.light }` safety.

- SwiftUI: root background `Color.white.ignoresSafeArea()` + `systemBackground.ignoresSafeArea()`, Discovery ScrollView background `AppColors.background.ignoresSafeArea(edges:[.top,.horizontal])` fills top, content respects safe area via `safeAreaPadding(.top,16)` + header top 48 so Dynamic Island doesn't overlap title.

- TabBar: each `NavigationStack` + `TabView` itself `.toolbarBackground(AppColors.cardBackground, for: .tabBar)` + `.visible`, UIKit `UITabBar.isTranslucent=false` + opaque `UITabBarAppearance` white.

- Light scheme forced `.preferredColorScheme(.light)` for Airbnb light polish; tokens remain adaptive, remove force to enable dark.

Result final-no-black.png 12:20: time black on white, no black bars, bottom white tab bar above home indicator.

## 9. Design System Deep Dive

Tokens enforce consistency, no hardcoded values.

- Colors: Color(hex:) sanitized Scanner, Color.adaptive(light:dark:) via UIColor trait, AppColors coral #FF385C teal #00A699 semantic backgrounds card text borders shadows badges hot #FF385C trending #222 superhost card, interactive heart/star/shimmer/mappin, mapPin locationAccent, shadow adaptive black 10%/40%, overlay light scrim.

- Typography: AppFont rounded size weight system rounded design default, display + shortcuts thin–black, AppTypography scale largeTitle 34 bold title1 28 title2 22 title3 20 headline 17 body 17 callout 16 subheadline 15 footnote 13 caption1 12 caption2 11 buttonLarge 17 bold price overline uppercase 11 tracking 0.6, modifiers AppTextStyle typography overlineStyle.

- Spacing: AppSpacing xxs 2 xs 4 s 8 sm 12 m 16 ml 20 l 24 xl 32 xxl 40 xxxl 56 huge 80 semantic cardPadding 16 screenHorizontal 24 sectionSpacing 32 itemSpacing 12. CornerRadius xs 4–full 9999 semantic card 16 large 24 button 12 pill 9999. Shadow xs–floating card black 8% r16 y4 ShadowModifier. Layout maxContentWidth 672 button heights searchBar 56 grid 2 animations springs. EdgeInsets helpers.

- Theme: AppTheme tokens + light/dark/current, ThemeKey env, ThemedBackground, CardBackgroundModifier, ThemedCardModifier, appThemedBackground themedCard cardBackground appTheme, AppAppearance.configure UIWindow white + TabBar opaque white isTranslucent false shadow, ThemePreviewContainer group light/dark.

- Components: RoundedCard generic with isPressed scale spring, PropertyCard 200 height AsyncImage shimmer trending badge wishlist heart, ActivityCard 160 HOT badge category, BadgeView hot uses flame.fill SF Symbol (not 🔥 emoji which shows "?" with rounded font), TrendingBadge SuperhostBadge, PrimaryButton AppButtonStyle primary/secondary/outline/ghost/destructive background/foreground/border/pressed + AppButtonSize small–extraLarge height font padding corner + IconButton GradientButton primaryGradient shadow, SearchField airbnbBar capsule magnifying placeholder clear filter slider circle stroke shadow, SectionHeader title subtitle seeAll, CarouselView generic TabView page indicators dots/pill/number/none + ImageCarouselView, ShimmerView skeletons, EmptyStateView icon title subtitle action, TagChip selectable pill icon, RatingView star rating count, PriceLabel Money amount suffix — all token-driven AsyncImage failure placeholder ultraThinMaterial ContentUnavailableView.

## 10. Core Models

All UUID Identifiable Codable Equatable Hashable Sendable, single source in Core/Models.

- GeoCoordinate Codable bridge lat/lng clCoordinate distance supports decoding lat/lng or latitude/longitude.
- Currency enum usd/eur/gbp/jpy/aud/cad/inr/aed symbol/displayName + Money amount Decimal currency formatted NumberFormatter +/- operator.
- UserPreferences currency temp unit language notification favoriteTypes Set FavoriteType priceAlerts distanceUnit default + enums TemperatureUnit DistanceUnit AppLanguage FavoriteType 11 beach..petFriendly icon.
- User id name email avatarURL createdAt preferences phone bio isVerified premium initials firstName isNewUser email valid preview guest.
- Destination id name country countryCode description imageURLs coordinates rating reviewCount isTrending tags activityIds propertyIds continent timezone bestMonths coverImageURL locationDisplay isHighlyRated preview.
- Property PropertyType hotel villa apartment etc icon + Amenity wifi pool kitchen ac parking gym spa beachfront petFriendly breakfast laundry workspace icon + Property fields title destinationId type pricePerNight currency rating reviewCount imageURLs amenities Set coordinates superhost trending hostId description maxGuests bedrooms beds bathrooms address instantBook cover totalPrice isLuxury formattedRating.
- Activity ActivityCategory 10 + Season + ActivityDuration minutes/hours displayString + Activity fields title destinationId description category price currency duration rating reviewCount imageURLs coordinates? isHot recommendedSeason tags isFreeCancellation provider cover formattedPrice.
- VacationOption id destination featuredProperties featuredActivities totalPriceEstimate currency nights tagline Popular Trending + averageRating pricePerNightEstimate.
- Wishlist WishlistType location/vacationType/custom icon + WishlistItem enum destination/property/activity custom Codable kind/id/destinationId/propertyId/activityId/addedAt referencedDestinationId kind factories destinationItem propertyItem activityItem + Wishlist fields title description? type items cover createdAt updatedAt isPrivate itemCount isEmpty destinations/properties/activities lastAddedAt mutations addItem removeItem.
- Trip TripStatus planned/ongoing/completed/cancelled icon + TimeSlot start end duration + TripActivity id activityId notes? timeSlot? isCompleted order cost? assignedMemberIds + TripDay id date title? activities notes? isLocked sortedActivities completedCount totalCost + Trip fields title notes? destinationIds startDate endDate status days bookingIds memberIds cover budget? currency isShared createdAt updatedAt durationDays durationDisplay dateRangeDisplay allActivities progress isUpcoming isActive totalEstimatedCost remainingBudget daysSorted addDay updateStatus.
- Booking BookingStatus pending..refunded isTerminal + BookingType hotel/flight/carRental/activity icon + Bookable protocol + Flight airline flightNumber fromCode toCode departure arrival durationMinutes price Money cabinClass stops + Hotel propertyId name checkIn out pricePerNight totalPrice guests rooms + CarRental company carModel carType pickup dropoff price + wrappers HotelBooking FlightBooking CarRentalBooking ActivityBooking title totalPrice currency status userId tripId? confirmationCode? + AnyBooking enum type-discriminated Codable type/payload.
- Collaboration Permission view/comment/edit/admin rank canPerform + Role owner/editor/viewer permission + TripMember isOwner canEdit canManage + InviteStatus + Invite isExpired isPending + TripShareLink id tripId createdBy url permission isActive expiresAt maxUses useCount createdAt title isExpired isValid shareableString + CollaborationSummary totalCollaborators owner.
- Alert AlertType weather/news/booking/price/trip/system icon + Severity info..critical rank + AlertProtocol + WeatherAlert condition temperature expiresAt + NewsAlert newsURL + BookingAlert bookingId type status actionRequired + PriceAlert relatedId type oldPrice newPrice dropPercentage savings + AnyAlert polymorphic + SimpleAppAlert alias AppAlert + RecentSearch + TrackedPriceItem priceDrop percent.

## 11. Storage Layer

Protocol 5 generics save/load/delete/exists/clearAll async throws + ~20 domain helpers as extension defaults built on primitives. InMemoryStorageService actor [String:Data] JSON iso8601 sortedKeys seedSync synchronous no Task race. MockDataStore async seed fast path mem seedSync else generic loop + makeSeededMemoryStorageSync semaphore blocking previews only. Keys namespace com.serperior.storage.*. Future UserDefaults/SwiftData TODO implementing only 5 primitives.

Tests isolated zero latency seeded synchronous recents dedup.

## 12. Service / API Layer Stubs

Each domain protocol Sendable async throws error LocalizedError DTOs latency Duration.zero default only sleeps if >zero deterministic.

- Booking: params HotelSearchParams destination destinationId? lat/lng checkIn/out guests rooms priceMin/Max minRating currency, FlightSearchParams origin destination departureDate returnDate? adults Cabin economy..first isOneWay currency, CarRentalSearchParams pickup dropoff pickupDate dropoff carType? currency, results HotelSearchResult hasMore totalCount, FlightSearchResult, CarRentalSearchResult, BookingConfirmation id booking AnyBooking confirmationCode message createdAt, methods searchHotels/Flights/CarRentals bookHotel/bookFlight/bookCar getBooking/getAllBookings(userId?) cancelBooking status checks.

- Maps: MapPin id coordinate title subtitle? type PinType destination/property/activity/user/hotel/flight, SuggestedRoute pins polyline [GeoCoordinate] totalDistanceMeters estimatedDurationMinutes formattedDistance, methods geocode reverseGeocode getPins destinationId tripId calculateRoute suggestedRoute trip searchNearby radius query, distance GeoCoordinate.distance.

- AI: AIDetailResponse title markdown highlights sources generatedAt confidence 0.85, SurpriseMeRequest startDate endDate location? budget currency travelers preferences [String], SurpriseMeResponse suggestedOption reasoning alternatives, methods fetchFlight/Booking/Activity/Destination details generateTripSuggestions surpriseMe filters budget <=1.2*budget location contains preferences disjoint deterministic.

- Alerts: AppAlert flattened id title message type severity timestamp destinationId? tripId? isRead actionURL?, methods fetchWeather destinationId fetchNews fetchAlerts tripId fetchAll userId markAsRead subscribe/unsubscribe, mock 4 samples heavy rain Bali high etc.

- PriceTracker: TrackedPriceItem original/current priceDrop percent, PriceHistoryPoint date price, PriceCheckResult trackedItem hasDropped dropPercent history, methods trackPrice type referenceId currentPrice currency untrack getTracked checkPriceChanges getPriceHistory.

FeatureFlags useMockServices true APIKeys empty placeholders. Live fallback explicit warning assertionFailure DEBUG.

## 13. Navigation Skeleton

System TabView 5 tabs Explore/Search/Wishlists/Trips/Maps selection selectedTab AppTab 5 cases Int title icon selectedIcon accessibility tab_*. Each tab NavigationStack path per-tab NavigationPath in AppState deep-link future. NavigationStack root DiscoveryView etc with toolbarBackground cardBackground visible for tabBar on each + TabView itself same (fixes iOS26 floating pill). Detail destinations navigationDestination Destination→Detail Property→Detail Activity→Detail Wishlist→Detail Trip→Detail CollaborationNav→CollaborationView ProfileDestination hub bookings/alerts/ai/priceTracker/collaboration/profile secondary via Profile hub avatar button (avoids coupling). RootView tint primary background white overlay error. Detail views compact inline toolbarBackground navBar visible.

## 14. Feature Vertical Slices

- Discovery: header Where to? Discover stays experiences AT avatar profile_button accessibility, search pill magnifying slider filter icon capsule AppColors.cardBackground stroke borderLight shadow black 5% radius 8 y2, Recommended for you subtitle count VacationCarousel Popular flame HOT badge Bali Indonesia from $1800 Trending 4.8 5 nights Kyoto Japan, Surprise Me budget $1500 circle sparkles pink Surprise button, Hot stays 🔥 section. VM configure.

- Search: SearchField + tags TagChip availableTags isSelected filter + recents dedup lowercased max20 + results AsyncImage 56 tags badge.

- Wishlists: List WishlistRow 64 image title itemCount type badge onDelete toolbar plus sheet AddEditWishlistView Form title description Type picker organization hint, Detail items icon.

- Trips: List Picker filter segmented All status TripRow status badge neutral/success/category dateRange progress bar duration destinations onDelete, Detail segmented Itinerary/Bookings/Collab/Budget page, Itinerary daysSorted sortedActivities checkmark.

- Maps: Picker destination menu Map Annotation Marker custom VStack systemIcon ticket.fill vs bed.double.fill vs mappin.circle.fill foreground accent/primary background white circle title caption2 ultraThinMaterial rounded MapPolyline stroke primary width 4 mapStyle standard route footer stops distance min horizontal TagChip background cardBackground.

- Booking: Picker type segmented hotel/flight/car SearchField Where to? Progress List sections Hotels Flights Car rentals Book button chart track alert booking confirmed.

- Collaboration: Trip Shared dates Members initials circle Editor badge Invite Section email role picker Send invite + Share Section Generate share link secondary link + SwiftUI.ShareLink item tripURL subject message Label.

- AI: chat bubbles HStack maxWidth 300 primary vs card shadow highlights TagChip suggestion horizontal chips TextField roundedBorder arrow button.

- Alerts: horizontal filter chips All + AlertType cases icon isSelected, List VStack icon severity title unread dot message timestamp swipe Read tint blue grouped background.

- Profile: user card initials gradient circle name email premium badge newBadge sections Plan Bookings PriceTracker Collaboration Assistant AI Weather & News alerts Preferences currency picker symbol displayName toggles notifications priceAlerts About version.

Per-feature README includes owner allowed Core only forbidden other Features TODOs testing second-container note.

## 15. Mock Data

7 destinations Bali ID trending tags beach tropical wellness family pet_friendly -8.4095 115 rating 4.9 etc Japan Greece Canada Mexico Switzerland USA. 4 properties Machiya Gion 320 2 bedrooms superhost trending, Oia 890 luxury, Jungle Treehouse cabin 185, SoHo 420. 4 activities Fushimi Inari hike 45 3h hot, Ubud Monkey Forest 65 8h hot, Caldera Sailing 120 5h hot, Pet-Friendly Beach Day family 30 pet tag. currentUser Alex Traveller, collaborators Sam Lee Jordan Silva Maya Patel. Wishlists Bali Dreams location, Family Friendly vacationType, Pet Adventures pet tag. Trips Kyoto Cherry Blossom Week planned +14d 7d days 2 budget 3500 shared true + Bali Wellness Escape ongoing. vacationOptions deterministic estimates 1800/2400/3200/1200/2100 tagline Popular Trending. sampleBookings hotel flight confirmed.

## 16. Testing

Unit 26: ModelTests 12 Currency symbol MoneyCodableRoundTrip GeoCoordinate distance DestinationProperty Activity WishlistItem polymorphic WishlistMutation Trip progress AnyBooking pet_friendly wishlistType; StorageServiceTests 6 saveLoad missing nil exists delete WishlistCRUD deterministic seeding immediate recent dedup case-insensitive; BookingServiceTests searchHotels non-empty zero latency flights filter HND book/cancel flow priceTracker; AIServiceTests AI destination markdown surpriseMe pet_friendly alternatives maps pins route alerts weather/price.

UI 3: AppLaunchTests app.launch runningForeground, NavigationTests tabBars existence 5 tabs navigable default tab Explore.

Picker hardened python next fallback instruction; -only-testing guidance; screenshots mask ignored foreground launch.

Shared scheme checked in.

## 17. Engineering Conventions

- Feature depends only Core (Models, Services protocols, DesignSystem, Utilities). No cross-feature imports. Use service protocol.
- Models only Core/Models.
- Service DTOs in Core/Services/<Domain>/ not Models.
- ViewModels @MainActor configure(with container) or configure(protocol), no Singleton in Views, resolve @EnvironmentObject.
- No hardcoded colors/fonts/spacing — use AppColors, AppTypography, AppSpacing, .typography(), .cardShadow(), .appShadow()
- Use MockDataProvider for previews injectDependencies(.preview)
- One writer to git index at a time — stage explicit file list for parallel teams (never git add -A)
- Branch feature/<name>-description
- Adding file: xcodegen generate after add (excludes README.md via project.yml) — no pbxproj merge conflict if adopt synchronized groups PBXFileSystemSynchronizedRootGroup objectVersion 77
- Appearance: DO NOT set UIView.appearance background globally — blanks images (fix3). Only UIWindow white + TabBar opaque via appearance + rest SwiftUI toolbarBackground modifiers.
- Color conversion: Avoid UIColor(Color(hex:)) round-trip for UIKit appearance — use system colors systemBackground/secondarySystemBackground for reliability; SwiftUI Color.adaptive uses UIColor trait closure OK but UIColor(Color) bridge may fail.
- Previews must inject container injectDependencies(.preview) or fallback warning safe mock.

## 18. Adding New File / Feature / Model / Service

- Add file under SerperiorTravellers/Features/<Name>/ or Core/...
- xcodegen generate
- Update feature README owner allowed/forbidden.
- If model changed team sync + storage tests + mock factory.
- If service protocol changed mock + container + tests.
- Run fast loop -only-testing private /tmp/st-dd.
- At group barrier full build+test.

## 19. Troubleshooting FAQ

- Black bars above/below → Info.plist UILaunchScreen present + UIDeviceFamily 1 + UIWindow white + root background ignoresSafeArea + Discovery background ignoring top/horizontal + safeAreaPadding top 16 header top 48 + toolbarBackground visible tabBar + light scheme.

- Floating pill overlapping → .toolbarBackground(cardBackground, for: .tabBar) .visible on each NavigationStack + TabView itself + UITabBar.isTranslucent=false opaque appearance.

- Popular "?" → Use SF Symbol flame.fill not emoji 🔥 with rounded font.

- Blank search pill / white cards after UIView.appearance white → Don't set UIView globally, only UIWindow + TabBar.

- #Preview macro not found on generic destination → Stripped for CI, re-add locally with injectDependencies(.preview).

- MapCameraPosition not found → Removed from VM, use @State position in view Map(position:) iOS17.

- DependencyContainer not injected early exit → fallback safe mock logging warning not fatal but EnvObject missing traps hard — inject at root via injectDependencies.

- Location crash → NSLocationWhenInUse in Info.plist via project.yml info.properties.

- Two status bars / screenshot outer black — App Switcher, not foreground. Ensure foreground launch via simctl launch + screenshot --mask=ignored after 3s.

## 20. Future Roadmap

Storage UserDefaults SwiftData, Live Booking Amadeus/Booking.com OAuth mapper AnyBooking toggle useMockServices false explicit, Live Maps CLGeocoder MKDirections polyline, AI LLM Claude/OpenAI streaming markdown, WeatherKit/OpenWeather, News API, Auth Sign in Apple Firebase, Image CDN Kingfisher/Nuke caching replace gradients, Notifications APNs booking confirm price drop check-in, Itinerary drag reorder onMove, Collaboration backend invite/share permission, Design token CI lint SwiftLint custom rule hardcoded colors/fonts, fully FS synchronized groups PBXFileSystemSynchronizedRootGroup for Features so pbxproj never mutates on file add.

## Spec

This repo includes the product spec at `Spec.md` — source of truth for product roadmap.

## License

Internal foundation scaffold — not for distribution. Apple frameworks only SwiftUI MapKit CoreLocation XCTest.
