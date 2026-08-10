import Foundation

public actor MockAIService: AIServiceProtocol {
    public var latency: Duration = .zero
    public init(latency: Duration = .zero) { self.latency = latency }

    private func simulateLatencyIfNeeded() async {
        guard latency > .zero else { return }
        try? await Task.sleep(for: latency)
    }

    public func fetchFlightDetails(flight: Flight) async throws -> AIDetailResponse {
        await simulateLatencyIfNeeded()
        return AIDetailResponse(
            title: "\(flight.airline) \(flight.flightNumber)",
            markdown: """
            **Flight \(flight.flightNumber)** – \(flight.fromCode) → \(flight.toCode)
            
            - Departure: \(flight.departureAt.formatted())
            - Duration: \(flight.durationMinutes) min, Stops: \(flight.stops)
            - Cabin: \(flight.cabinClass)
            - Price: \(flight.price.formatted)
            
            This is a popular direct route with on-time performance 92%. We recommend online check-in 24h before departure.
            """,
            highlights: ["Direct flight", "92% on-time", "Free carry-on"],
            sources: []
        )
    }

    public func fetchBookingDetails(booking: AnyBooking) async throws -> AIDetailResponse {
        await simulateLatencyIfNeeded()
        switch booking {
        case .hotel(let hb):
            return AIDetailResponse(
                title: hb.hotel.name,
                markdown: "**\(hb.hotel.name)** – \(hb.status.displayName). Confirmation \(hb.confirmationCode ?? "-"). Amenities include Wi-Fi and flexible cancellation. Near top attractions.",
                highlights: ["Superhost", "Free cancellation"]
            )
        case .flight(let fb):
            return try await fetchFlightDetails(flight: fb.outbound)
        case .carRental(let cb):
            return AIDetailResponse(title: cb.carRental.company, markdown: "**\(cb.carRental.carModel)** pickup at \(cb.carRental.pickupLocation). Full insurance recommended.", highlights: ["Unlimited mileage"])
        case .activity(let ab):
            return AIDetailResponse(title: ab.title, markdown: "**\(ab.title)** – \(ab.totalPrice) \(ab.currency.rawValue). Scheduled \(ab.scheduledAt.formatted(date: .abbreviated, time: .shortened)).", highlights: ["Instant confirmation"])
        }
    }

    public func fetchActivityDetails(activity: Activity) async throws -> AIDetailResponse {
        await simulateLatencyIfNeeded()
        return AIDetailResponse(
            title: activity.title,
            markdown: """
            **\(activity.title)** – \(activity.category.displayName)
            
            \(activity.description)
            
            Duration \(activity.duration.displayString) • Rating \(String(format: "%.1f", activity.rating)) (\(activity.reviewCount) reviews)
            Price \(activity.formattedPrice) • Free cancellation: \(activity.isFreeCancellation ? "Yes" : "No")
            
            Tip: Book 2 days ahead for best availability.
            """,
            highlights: activity.tags + [activity.category.displayName],
            sources: []
        )
    }

    public func fetchDestinationDetails(destination: Destination) async throws -> AIDetailResponse {
        await simulateLatencyIfNeeded()
        return AIDetailResponse(
            title: destination.name,
            markdown: """
            **\(destination.name), \(destination.country)** – \(destination.description)
            
            Trending: \(destination.isTrending ? "🔥 Yes" : "No") • Rating \(destination.rating) • \(destination.reviewCount) reviews
            
            Best months: \(destination.bestMonths.map(String.init).joined(separator: ", "))
            Tags: \(destination.tags.joined(separator: ", "))
            Coordinates: \(destination.coordinates.latitude), \(destination.coordinates.longitude)
            """,
            highlights: destination.tags
        )
    }

    public func generateTripSuggestions(for trip: Trip) async throws -> [AIDetailResponse] {
        await simulateLatencyIfNeeded()
        return [
            AIDetailResponse(title: "Add local food tour", markdown: "Consider adding a food tour for \(trip.title) – highly rated by travelers with similar preferences.", highlights: ["Food & Drink"]),
            AIDetailResponse(title: "Check weather", markdown: "Average temperature for your dates is mild. Pack light layers.", highlights: ["Weather"])
        ]
    }

    public func surpriseMe(request: SurpriseMeRequest) async throws -> SurpriseMeResponse {
        await simulateLatencyIfNeeded()
        let all = MockDataProvider.vacationOptions
        // Filter by budget & preferences deterministically
        let budget = NSDecimalNumber(decimal: request.budget).doubleValue
        var filtered = all.filter { NSDecimalNumber(decimal: $0.totalPriceEstimate).doubleValue <= budget * 1.2 }
        if let loc = request.location, !loc.isEmpty {
            filtered = filtered.filter { $0.destination.name.localizedCaseInsensitiveContains(loc) || $0.destination.country.localizedCaseInsensitiveContains(loc) }
        }
        if !request.preferences.isEmpty {
            filtered = filtered.filter { opt in
                !Set(opt.destination.tags).isDisjoint(with: request.preferences)
            }
        }
        let chosen = filtered.first ?? all[1]
        let others = all.filter { $0.id != chosen.id }.prefix(2)
        let reasoning: String
        if request.budget == 0 {
            reasoning = "Surprise! Since you had no budget limit, we picked \(chosen.destination.name) for its \(chosen.destination.tags.joined(separator: ", ")) vibe and excellent \(chosen.averageRating) rating."
        } else {
            reasoning = "Based on your budget \(request.currency.symbol)\(request.budget) for \(request.travelers) travelers from \(request.startDate.formatted(date: .abbreviated, time: .omitted)) to \(request.endDate.formatted(date: .abbreviated, time: .omitted)), \(chosen.destination.name) offers the best value with estimated \(chosen.totalPriceEstimate) for \(chosen.nights) nights. Preferences \(request.preferences.joined(separator: ", ")) matched \(chosen.destination.tags.joined(separator: ", "))."
        }
        return SurpriseMeResponse(suggestedOption: chosen, reasoning: reasoning, alternatives: Array(others))
    }
}
