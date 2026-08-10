import Foundation

@MainActor
public final class BookingViewModel: ObservableObject {
    @Published public var hotels: [Hotel] = []
    @Published public var flights: [Flight] = []
    @Published public var cars: [CarRental] = []
    @Published public var isLoading = false
    @Published public var searchType: BookingType = .hotel
    @Published public var query: String = ""
    @Published public var confirmation: BookingConfirmation?

    private var bookingService: BookingServiceProtocol?
    private var priceTracker: PriceTrackerServiceProtocol?

    public init() {}

    public func configure(booking: BookingServiceProtocol, priceTracker: PriceTrackerServiceProtocol) {
        self.bookingService = booking
        self.priceTracker = priceTracker
        Task { await search() }
    }

    public func search() async {
        guard let bookingService else { return }
        isLoading = true
        do {
            switch searchType {
            case .hotel:
                let params = HotelSearchParams(destination: query)
                hotels = (try await bookingService.searchHotels(params: params)).hotels
            case .flight:
                let params = FlightSearchParams(origin: "SFO", destination: query.isEmpty ? "HND" : query)
                flights = (try await bookingService.searchFlights(params: params)).flights
            case .carRental:
                let params = CarRentalSearchParams(pickupLocation: query)
                cars = (try await bookingService.searchCarRentals(params: params)).rentals
            case .activity:
                break
            }
        } catch {
            print("Booking search failed: \(error)")
        }
        isLoading = false
    }

    public func bookHotel(_ hotel: Hotel, userId: UUID) async {
        guard let bookingService else { return }
        isLoading = true
        do {
            let params = HotelSearchParams(destination: hotel.name)
            confirmation = try await bookingService.bookHotel(hotel: hotel, params: params, guestName: "Alex", userId: userId)
        } catch { print(error) }
        isLoading = false
    }

    public func trackPrice(type: BookingType, referenceId: UUID, price: Decimal) {
        Task { _ = try? await priceTracker?.trackPrice(type: type, referenceId: referenceId, currentPrice: price, currency: .usd) }
    }
}
