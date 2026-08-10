# Booking Feature — Hotels, Flights, Car Rentals + Price Tracker Hook

**Owner:** @team-booking
**Allowed:** Core/Models Flight Hotel CarRental AnyBooking BookingType Currency Money, Core/Services/Booking BookingModels BookingServiceProtocol, PriceTracker TrackedPriceItem, Core/DesignSystem
**Forbidden:** Other Features

## Files
- BookingSearchView.swift — env dependencies appState VM BookingViewModel + showConfirmation Bool VStack Picker Type segmented hotel/flight/car BookingType + SearchField query placeholder Where to? Hotels flights cars + ProgressView isLoading + List switch type Section Hotels ForEach hotels VStack title headlineSmall price/night guests PrimaryButton Book Task await bookHotel userId showConfirmation true + chart button trackPrice + flight section airline flightNumber from→to departs formatted duration minutes cabin + price + car rentals company model pickupLocation carType price. background grouped navTitle inline .task configure booking dependencies.bookingService priceTracker dependencies.priceTrackerService onChange searchType search + alert Booking Confirmed confirmationCode message.
- BookingViewModel.swift — @MainActor @Published hotels flights cars isLoading searchType BookingType query confirmation BookingConfirmation? bookingService? priceTracker? configure booking priceTracker Task search search async switch type HotelSearchParams destination query etc FlightSearchParams origin SFO destination query isEmpty ? HND : query CarRentalSearchParams pickup query searchHotels searchFlights searchCarRentals + bookHotel + trackPrice Task tracker trackPrice.

## Spec
- Integrate travel APIs hotels flights car rentals search+booking → BookingServiceProtocol.
- Price tracker generic tracker monitors flight/hotel prices selected dates → PriceTrackerService trackPrice + PriceTrackerView in App/RootView.
- Booking notifications notify confirmation check-in departure once route decided → BookingAlert in MockAlertService.

## DI
configure(booking:priceTracker:) via env. MockBookingService latency zero deterministic via MockBookingFactory.

## Testing
BookingServiceTests searchHotels non-empty zero latency flight filter destination HND bookAndCancel flow confirmationCode type hotel cancelled status.

## TODOs
- Implement BookingDetailView for hotel/flight/car detail + amenities.
- Wire booking to trip via saveBooking + add bookingId to trip days.
- Price tracker history chart + notifications.
