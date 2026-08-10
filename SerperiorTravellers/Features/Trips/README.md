# Trips Feature — My Trips + Itinerary Calendar

**Owner:** @team-trips
**Allowed:** Core/Models Trip TripStatus TripDay TripActivity TimeSlot, Core/Storage, Core/DesignSystem
**Forbidden:** Other Features (Booking used via BookingService protocol not direct import)

## Files
- TripsView.swift — EmptyStateView vs List Picker filter segmented All + TripStatus Cases TripRow(title status badge neutral/success/category dateRangeDisplay progress bar duration destinations) onDelete + background grouped + navigationTitle My Trips .task configure storage refreshable load.
- TripsViewModel.swift — trips filter optional TripStatus isLoading filteredTrips sorted startDate descending filter if set, configure storage load async via loadTrips else mock, deleteTrip remove + storage delete.
- TripDetailView trip: Trip selectedTab 0..3 Picker segmented Itinerary/Bookings/Collab/Budget TabView page indicator never 0 ItineraryView 1 BookingListForTrip 2 CollaborationView 3 TripBudgetView background grouped navTitle inline.
- ItineraryView trip: Trip List if empty hint + ForEach daysSorted Section header date abbreviated title headline + ForEach sortedActivities HStack VStack title category star rating etc assignedMember + completion checkmark.
- BookingListForTrip trip: Trip Section bookings linked to trip bookingIds placeholder.
- TripBudgetView trip: Trip LabeledContent budget / estimated / remaining red vs green.

## Spec
- My Trips page shows active vacation plans → TripsView list.
- Calendar/itinerary visualize schedule day by day track activities → ItineraryView TripDay + TripActivity ordered + completion + notes.

## DI
configure(storage:) via env dependencies. No default.

## TODOs
- Real calendar integration EventKit, drag to reorder activities, budget calculation remaining.
- Add trip creation flow with destination picker + date range.

## Testing
ModelTests testTripDurationAndProgress, StorageServiceTests seeded trips non-empty.
