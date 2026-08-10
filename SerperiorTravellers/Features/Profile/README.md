# Profile Feature — Hub for Secondary Screens + Preferences

**Owner:** @team-profile (also hub for Booking/AI/Alerts collaboration secondary)
**Allowed:** Core/Models User Currency UserPreferences, Core/Constants AppConstants version, Core/DesignSystem

## Files
- ProfileView.swift — env appState dependencies pathTrigger Optional ProfileDestination List Section user card initials gradient primaryGradient circle 60 name title3 email caption1 secondary premium badge newBadge if isPremium Section Plan NavigationLink values ProfileDestination.bookings My Bookings ticket, priceTracker chart, collaboration person.2 Section Assistant Alerts AI Assistant sparkles, Weather & News Alerts cloud.bolt Section Preferences Picker currency ForEach symbol displayName tag, Toggle notifications priceAlertsEnabled bound appState.preferences Section About LabeledContent version appVersion appName. listStyle insetGrouped navTitle Profile background grouped.

## Navigation Hub
Per final design doc: secondary screens (Booking, AI, Alerts, Collaboration, Profile/PriceTracker) reached via Profile as hub via ProfileDestination enum bookings/alerts/ai/priceTracker/collaboration/profile + ProfileDestinationView in RootView switch returns real roots BookingSearchView etc. This avoids coupling 5 features to Discovery toolbar and keeps one toolbar uncluttered.

## DI
Uses appState currentUser preferences + dependencies not services directly.

## TODOs
- Edit profile, avatar AsyncImage, verified badge, logout flow, settings persistence via StorageService savePreferences.
