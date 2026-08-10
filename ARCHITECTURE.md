# Architecture — Serperior Travellers (iPhone-only, SwiftUI, Polished)

**Date:** 2026-08-10 (black bars & tab bar polish)
**Platform:** iPhone-only SwiftUI iOS 17+, Xcode 16+ objectVersion 77, Swift 5, no third-party, Bundle com.serperiortravellers.app
**Spec:** `Spec.md` in repo root

## Table of Contents

1. Goal & Product Scope
2. Key Decisions
3. Folder Layout & Project.yml & Info.plist
4. Scene & Window Configuration — Black Bars Fix
5. App Layer — Composition Root, Window White, Light Scheme, Seeding
6. Core Models — Single Source Truth
7. Storage — Protocol + Actor + Deterministic Seeding
8. Services — Protocol-First + Mock Actor Zero Latency
9. DesignSystem — Tokens + Components + Badge Flame Fix
10. Navigation — System TabView 5 Tabs + Per-Tab NavigationPath + ToolbarBackground
11. Feature Vertical Slices
12. Mock Data Deterministic + Pet-Friendly
13. Testing — Unit + UI + Picker + Screenshots
14. File Ownership Parallel Team
15. Future Live Wiring
16. How to Add Model / Service / Feature
17. FAQ for AI & Human Ramp-up

## 1. Goal & Product Scope

Foundation scaffold for parallel engineers and SWE task authoring. Airbnb-inspired vacation planning for iPhone only with minimal skeleton: navigation + models + protocols + design system token-clean, screens placeholders but polished spec-compliant via mocks. The codebase must scale to many contributors without stepping on each other.

Product roadmap (Spec.md): vacation carousel scrollable popular 🔥 badge, hot properties/attractions, activity recommendations when destination entered, Surprise Me period/location/budget best vacation, basic text search locations, wishlists by Location/Vacation type family-friendly pet-friendly + add/edit, booking hotels flights car rentals + price tracker generic + notifications confirmation check-in departure, location map user+destinations pins suggested route, My Trips active plans, calendar itinerary day-by-day, invite family/friends shared trips + share via link, AI richer details on flight/booking/activity on demand, weather/news alerts, storage users/prefs/wishlists/trips/bookings.

## 2. Key Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Scaffold depth | Minimal skeleton | nav+models+protocols+design system placeholder token-clean maximizes room |
| Module boundaries | Convention single .xcodeproj + xcodegen scripted objectVersion77 | Simplest, boundaries via folder+per-feature READMEs+ownership table, pbxproj merge risk mitigated deterministic generation + future FS synchronized groups recommendation |
| Storage | Protocol + in-memory actor only 5 primitives | StorageServiceProtocol + InMemoryStorageService actor, domain helpers as extension defaults, TODO UserDefaults/SwiftData authorable |
| Tests CI | Headless build+test shared scheme checked in valid assets | Unit+UI + shared scheme xcshareddata checked in Test wired both bundles, .gitignore keeps xcshareddata via !, picker hardened, -only-testing, mask=ignored screenshots |
| Navigation | System TabView 5 tabs + per-tab NavigationPath + toolbarBackground | Simple for task authors, UITest app.tabBars buttons working, deep-link future, fixes iOS26 floating blur pill overlapping cards via toolbarBackground opaque visible |
| Appearance | Light forced for polished Airbnb vibe | Tokens adaptive but App forces light via preferredColorScheme light + window override light + UIWindow white — kills black bars top/bottom and ensures time black on white (final 12:20), dark can be re-enabled by removing force |
| Scene | UILaunchScreen + UIDeviceFamily 1 iPhone-only + portrait | Without UILaunchScreen window background black persists; universal [1,2] can letterbox. Info.plist now custom file with UILaunchScreen ensures white launch + white window kills black bars above/below. |

## 3. Folder Layout & Project.yml & Info.plist

```
project.yml:
  name SerperiorTravellers
  options bundleIdPrefix com.serperiortravellers deploymentTarget iOS 17.0 xcodeVersion 16.0 generateEmptyDirectories createIntermediateGroups
  settings base SWIFT_VERSION 5.0 TARGETED_DEVICE_FAMILY 1 GENERATE_INFOPLIST_FILE NO INFOPLIST_FILE SerperiorTravellers/Resources/Info.plist MARKETING_VERSION 1.0.0 CODE_SIGNING_ALLOWED NO
  schemes SerperiorTravellers build all + run Debug executable + test Debug unit+UI + archive Release
  targets:
    SerperiorTravellers type application platform iOS deploymentTarget 17.0 info path Resources/Info.plist properties UIApplicationSceneManifest SupportsMultipleScenes true UISceneConfigurations {} UILaunchScreen {UILaunchScreen:{}} UISupportedInterfaceOrientations portrait NSLocationWhenInUse NSAccentColorName CFBundleDisplayName + sources path SerperiorTravellers excludes **/README.md **/*.md Resources/Info.plist + settings PRODUCT_BUNDLE_IDENTIFIER com.serperiortravellers.app TARGETED_DEVICE_FAMILY 1 GENERATE NO INFOPLIST_FILE + IndirectInputEvents YES
    Tests unit+ui TARGETED_DEVICE_FAMILY 1 etc

SerperiorTravellers.xcodeproj/ project.pbxproj objectVersion77 + xcshareddata/xcschemes/SerperiorTravellers.xcscheme checked in

SerperiorTravellers/
  App/ SerperiorTravellersApp.swift @main window white light seed, RootView.swift system TabView 5 tabs each NavigationStack path AppState toolbarBackground tabBar visible detail views, AppState.swift selectedTab 5 + 6 NavigationPath search caches isWishlisted, DependencyContainer.swift composition root storage+5 services mock/live warning assertionFailure DEBUG seedIfNeeded deterministic fallback safe mock logging not fatal + _unsafeFallback nonisolated assumeIsolated + injectDependencies
  Core/
    Models/ GeoCoordinate Codable bridge + Currency Money single source + UserPreferences 11 FavoriteTypes petFriendly + User + Destination + Property type amenity + Activity category duration + VacationOption + Wishlist type polymorphic item factories + Trip status TimeSlot TripActivity TripDay progress budget + Booking status isTerminal type icon Bookable Flight Hotel CarRental wrappers AnyBooking type-discriminated + Collaboration Permission rank Role TripMember Invite TripShareLink renamed + Alert type severity WeatherAlert NewsAlert BookingAlert PriceAlert AnyAlert SimpleAppAlert alias + RecentSearch TrackedPriceItem
    Storage/ StorageService.swift StorageError StorageKey namespace com.serperior.storage.* protocol 5 primitives + domain helpers extension defaults + InMemoryStorageService actor [String:Data] JSON iso8601 sortedKeys seedSync synchronous + MockDataStore async seed fast path + blocking semaphore previews
    Services/ AI AIService AIDetailResponse SurpriseMeRequest/Response + MockAIService latency zero reasoning, Alerts AlertService MockAlertService 4 samples, Booking BookingModels DTOs HotelSearchParams FlightSearchParams CarRentalSearchParams result BookingConfirmation + BookingService protocol + MockBookingService actor factory, Maps MapsService MapPin SuggestedRoute + MockMapsService, PriceTracker protocol Mock preload history
    DesignSystem/ Colors hex adaptive AppColors coral teal semantic + Typography rounded AppTypography scale + Spacing 4pt CornerRadius Shadow Layout + Theme AppTheme light/dark/current + appTheme env + CardBackgroundModifier + AppAppearance configure UIWindow white + TabBar opaque white isTranslucent false + ThemePreviewContainer, Components/ RoundedCard PropertyCard ActivityCard BadgeView flame.fill for hot PrimaryButton SearchField SectionHeader CarouselView Shimmer EmptyState TagChip RatingView PriceLabel token-driven AsyncImage shimmer failure.
    Utilities/ Constants AppConstants FeatureFlags useMockServices APIKeys UI Pagination Defaults + Extensions Color View + MockDataProvider deterministic
  Features/ 10 slices View+VM+README owner allowed Core only forbidden other Features
  Resources/ Assets.xcassets valid + Info.plist with UILaunchScreen + orientation + scene + device family 1 + NSLocation + AccentColor excluding MD files
Tests/ ModelTests StorageServiceTests BookingServiceTests AIServiceTests 26 green + AppLaunchTests NavigationTests 3 green tabBars
scripts/pick-simulator.sh hardened
Spec.md — product spec source of truth
README.md ARCHITECTURE.md .gitignore build DerivedData xcuserdata DS_Store cache excluded xcshareddata kept
```

**Ownership** (suggested): Discovery, Search, Wishlists, Trips, Maps, Booking, Collaboration, AI, Alerts, DesignSystem, Storage/Data table as in README.

## 4. Scene & Window Configuration — Black Bars Fix

Symptom Image 1-6: black space above app (status bar area black white time 11:56) + below tab bar black below home indicator. Also screenshot double status bar when app switcher (outer white on black + inner gray).

Causes:
- Info.plist missing UILaunchScreen → launch background black, window defaults black.
- UIDeviceFamily universal [1,2] → iPad letterboxing.
- NavigationStack .toolbar(.hidden) hides nav bar whose background extends under status bar; background not ignoring safe area → window black visible top.
- Root TabView background not ignoring safe area → window black bottom.
- simctl io screenshot default --mask=black renders display mask (rounded + Dynamic Island) as black; plus app not foreground shows App Switcher wallpaper dark gradient with blurred dock.

Fix:

1. Info.plist custom file under Resources: UILaunchScreen dict {UILaunchScreen:{}} empty white launch, UIDeviceFamily [1] iPhone-only, UISupportedInterfaceOrientations portrait, UIApplicationSceneManifest SupportsMultipleScenes true UISceneConfigurations {} empty, NSLocation..., NSAccentColorName, CFBundleDisplayName. Project.yml uses info.path Resources/Info.plist properties + target INFOPLIST_FILE path + GENERATE NO.

2. UIWindow: appearance white `UIWindow.appearance().backgroundColor = .white` only (not UIView globally which blanked images/search pill after-fix3). Plus App onAppear paints `windowScene.windows.forEach { $0.backgroundColor=.white; $0.overrideUserInterfaceStyle=.light }`.

3. SwiftUI: root background `Color.white.ignoresSafeArea()` + `systemBackground.ignoresSafeArea()`, Discovery ScrollView background `AppColors.background.ignoresSafeArea(edges:[.top,.horizontal])` fills top, content respects safe area via `safeAreaPadding(.top,16)` + header top 48 to avoid Dynamic Island overlap (Image 12:14 showed Where to? under island). Remove `.ignoresSafeArea(edges:.top)` on ScrollView itself.

4. TabBar: each NavigationStack + TabView `.toolbarBackground(AppColors.cardBackground, for: .tabBar)` + `.visible`, UIKit `UITabBar.isTranslucent=false` + opaque `UITabBarAppearance` white shadow.

5. Light scheme forced `.preferredColorScheme(.light)` ensures time black on white (final 12:20) not white on black. Tokens adaptive remain, remove force to enable dark.

6. Screenshots: `--mask=ignored` to ignore rounded corners mask, ensure foreground launch `simctl launch`.

Result final-no-black.png 12:20: time black on white, no black bars top/bottom, tab bar white above home indicator.

## 5. App Layer

SerperiorTravellersApp: @StateObject dependencies mock latency zero + appState, init AppAppearance.configure UIWindow white TabBar opaque, WindowGroup RootView envObject appState+dependencies env dependencies tint primary background white/systemBackground ignoresSafeArea preferred light task seedIfNeeded onAppear window white light.

RootView: ContentTabView tint background overlay error.

ContentTabView: system TabView selection selectedTab, 5 tabs NavigationStack(path:) per-tab path AppState, toolbarBackground cardBackground visible for tabBar on each + TabView itself fixes floating pill, tabItem Label systemImage + tag.

Detail views background ignoresSafeArea toolbarBackground navBar visible + bottom padding 90 above tab bar.

AppState: selectedTab 5 cases etc per-tab NavigationPath search caches isWishlisted.

DependencyContainer: @MainActor composition root holds storage + 5 services, mock/live switch explicit warning assertionFailure DEBUG, seedIfNeeded deterministic, preview + makeTestContainer zero latency, EnvironmentKey fallback safe mock logging warning not fatal (prevents Early exit when unit-test host launches) + _unsafeFallback nonisolated assumeIsolated.

## 6. Core Models Single Source Truth

Identifiable Codable Equatable Hashable Sendable UUID offline-first, single source Core/Models, no duplication Currency/Mone, GeoCoordinate bridge.

Details exhaustive as README §10.

## 7. Storage

Protocol 5 primitives + 20 helpers defaults, actor thread-safe [String:Data] JSON iso8601 seedSync synchronous, MockDataStore async seed deterministic fast path mem else generic.

Keys namespace com.serperior.storage.*.

Future UserDefaults/SwiftData TODO only 5 primitives.

## 8. Services

Each domain protocol Sendable async throws error LocalizedError DTOs actor Mock latency Duration zero deterministic.

5 domains: Booking params DTOs results BookingConfirmation + Mock factory MockDataProvider.MockBookingFactory; Maps MapPin SuggestedRoute geocode etc; AI AIDetailResponse SurpriseMeRequest/Response reasoning alternatives; Alerts AppAlert flattened; PriceTracker TrackedPriceItem PriceHistoryPoint PriceCheckResult.

FeatureFlags useMockServices true APIKeys empty placeholders, live fallback explicit logged assertionFailure.

## 9. DesignSystem

Tokens: Colors hex sanitized Scanner + adaptive via UIColor trait light dark + AppColors coral #FF385C teal #00A699 semantic etc badges hot #FF385C trending #222 etc text etc shadow adaptive. Non-named assets avoided, only AccentColor exists valid Contents.json.

Typography rounded design largeTitle 34 bold title1-3 headline body callout subheadline footnote caption price badge overline modifiers .typography.

Spacing AppSpacing xxs-xxl semantic cardPadding screenHorizontal sectionSpacing + CornerRadius xs-full semantic card 16 large 24 button 12 pill + Shadow xs-floating card black 8% radius16 y4 ShadowModifier + Layout + EdgeInsets.

Theme AppTheme tokens current light/dark + ThemeKey env + modifiers ThemedBackground CardBackgroundModifier ThemedCardModifier + AppAppearance minimal UIWindow white TabBar opaque not UIView globally + ThemePreviewContainer.

Components token-driven ViewModel-agnostic AsyncImage shimmer failure ultraThinMaterial ContentUnavailableView token-clean: RoundedCard generic, PropertyCard 200 image trending badge wishlist heart, ActivityCard HOT badge category, BadgeView styles hot uses flame.fill SF Symbol 10pt semibold white on pink (fixes "?" placeholder emoji rounded font unreliable), PrimaryButton variants sizes isEnabled alias IconButton GradientButton haptic, SearchField airbnbBar pill capsule borderLight shadow, SectionHeader, CarouselView generic TabView page indicators, ShimmerView skeletons, EmptyStateView, TagChip selectable pill, RatingView star, PriceLabel Money amount suffix.

Polish Airbnb: large imagery 4:3, rounded 16-24, generous spacing, soft shadows.

## 10. Navigation

System TabView 5 tabs Explore/Search/Wishlists/Trips/Maps (not custom bar) so UITest app.tabBars.buttons queries work. Each NavigationStack path per-tab NavigationPath in AppState deep-link future. ProfileDestination hub secondary for bookings/alerts/ai/priceTracker/collaboration/profile secondary via Profile hub avatar avoids 5 features coupling to Discovery.

ToolbarBackground visible for tabBar on each NavigationStack + TabView itself fixes iOS26 floating blur pill overlapping cards. Detail views toolbarBackground navBar visible ensures pushed detail not black.

Discovery header custom "Where to? Discover stays & experiences" AT avatar profile_button accessibility search pill Button appends SearchNavigationTrigger, Recommended subtitle count, VacationCarousel 280 Popular flame badge Bali Indonesia from $1800 Trending 4.8 5 nights Kyoto, Surprise Me budget $1500 sparkles pink Surprise button, Hot stays.

## 11. Feature Vertical Slices

Each Features/<Name>/ View+VM+README owner allowed Core only forbidden other Features TODOs testing second-container note.

Details per-feature as README §14 + per-feature README files updated enhanced.

## 12. MockData Deterministic

7 destinations Bali trending pet_friendly etc 5 options deterministic estimates, 4 properties, 4 activities incl pet-friendly beach day, currentUser Alex Traveller, collaborators 3, wishlists Bali Dreams Family Friendly Pet Adventures, trips Kyoto planned +14d and Bali ongoing, vacationOptions deterministic tagline, sampleBookings hotel flight confirmed via MockBookingFactory makeHotels makeFlights makeCars.

## 13. Testing

InMemoryStorageService isolated, mocks latency zero deterministic, ModelTests 12, StorageServiceTests 6 (seeded immediate, recent dedup case-insensitive), BookingServiceTests 4, AIServiceTests 4, AppLaunchTests 1, NavigationTests 2 tabBars existence 5 tabs reachable default tab. Picker hardened python next fallback instruction + abort. Fast single test via -only-testing. Shared scheme checked in.

Screenshots mask ignored.

## 14. File Ownership Parallel Team

ObjectVersion77 mitigates but per-file still. Recommend PBXFileSystemSynchronizedRootGroup FS synchronized groups for Features/ so adding file doesn't touch pbxproj. One writer barrier per group plan: per-step per-feature own files only + TODO/C3, serialized commits at barrier, authoritative build/test on /tmp/st-dd private derived data + simctl for per-step.

If can't Xcode16, doc merge convention small frequently rebased diffs whoever lands first wins pbxproj hunks.

## 15. Future Live Wiring

UserDefaults/SwiftData only 5 primitives. LiveBooking via Amadeus OAuth mapper AnyBooking. LiveMaps CLGeocoder MKDirections polyline. LiveAI Claude/OpenAI. WeatherKit OpenWeather. Auth. CDN caching Kingfisher Nuke. APNs booking confirm price drop check-in. Itinerary reorder onMove. Collaboration backend invite/share permission. Lint token CI grep Color(red: / .font(.system(size:. Design token lint. Fully FS synchronized groups.

## 16. How to Add Model/Service/Feature

Steps: new model file Core/Models new struct Identifiable Codable Sendable Hashable UUID defaults + MockDataProvider + Codable roundtrip test + xcodegen generate build gate. Service: protocol Sendable async throws + error + DTOs + actor Mock latency zero seeded + DependencyContainer hold + test file. Feature: Features/<Name>/ View+VM+README token-clean configure(with:) @EnvironmentObject dependencies @StateObject VM task configure + Components/ + README owner allowed Core forbidden + wire in RootView ContentTabView AppTab or ProfileDestination hub + xcodegen generate fast loop -only-testing + barrier full build+test. Storage backend implement only 5 primitives. Design token add Colors Typography Spacing Shadow token generic component consumes only tokens preview injection.

## 17. FAQ

- Black bars? UILaunchScreen present + UIDeviceFamily 1 + UIWindow white + background ignoringSafeArea + header top 48 safeAreaPadding 16 + toolbarBackground visible tabBar + light scheme.

- Floating pill? toolbarBackground visible opaque + isTranslucent false.

- "?" badge? flame.fill SF Symbol.

- Blank pill/cards? Don't set UIView.appearance globally only UIWindow+TabBar.

- Preview macro? Stripped for CI generic destination mask black issue, re-add locally with injectDependencies(.preview).

- MapCameraPosition not found? Removed from VM, use State in view.

- DI not injected early exit? fallback safe mock logging not fatal but EnvObject traps hard — inject at root.

- Location crash? NSLocationWhenInUse in Info.plist via project.yml info.properties.

- Double status bar screenshot? App Switcher, ensure foreground launch.

- Build warning toolchain pika...? Ignore, extra toolchain missing Info.plist.

## Spec

Product spec at `Spec.md` in repo root — source of truth.

## License

Internal scaffold, Apple frameworks only.

