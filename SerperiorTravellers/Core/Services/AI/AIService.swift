import Foundation

public enum AIServiceError: LocalizedError {
    case notAvailable
    case generationFailed(String)
    case invalidInput(String)
    public var errorDescription: String? {
        switch self {
        case .notAvailable: return "AI assistant not available"
        case .generationFailed(let m): return "AI generation failed: \(m)"
        case .invalidInput(let m): return "Invalid input: \(m)"
        }
    }
}

public struct AIDetailResponse: Codable, Sendable, Equatable {
    public var title: String
    public var markdown: String
    public var highlights: [String]
    public var sources: [URL]
    public var generatedAt: Date
    public var confidence: Double

    public init(title: String, markdown: String, highlights: [String] = [], sources: [URL] = [], generatedAt: Date = Date(), confidence: Double = 0.85) {
        self.title = title; self.markdown = markdown; self.highlights = highlights; self.sources = sources; self.generatedAt = generatedAt; self.confidence = confidence
    }
}

public struct SurpriseMeRequest: Codable, Sendable, Equatable {
    public var startDate: Date
    public var endDate: Date
    public var location: String?
    public var budget: Decimal
    public var currency: Currency
    public var travelers: Int
    public var preferences: [String]

    public init(startDate: Date, endDate: Date, location: String? = nil, budget: Decimal, currency: Currency = .usd, travelers: Int = 2, preferences: [String] = []) {
        self.startDate = startDate; self.endDate = endDate; self.location = location; self.budget = budget; self.currency = currency; self.travelers = travelers; self.preferences = preferences
    }
}

public struct SurpriseMeResponse: Sendable, Equatable {
    public var suggestedOption: VacationOption
    public var reasoning: String
    public var alternatives: [VacationOption]
    public init(suggestedOption: VacationOption, reasoning: String, alternatives: [VacationOption]) {
        self.suggestedOption = suggestedOption; self.reasoning = reasoning; self.alternatives = alternatives
    }
}

public protocol AIServiceProtocol: Sendable {
    func fetchFlightDetails(flight: Flight) async throws -> AIDetailResponse
    func fetchBookingDetails(booking: AnyBooking) async throws -> AIDetailResponse
    func fetchActivityDetails(activity: Activity) async throws -> AIDetailResponse
    func fetchDestinationDetails(destination: Destination) async throws -> AIDetailResponse
    func generateTripSuggestions(for trip: Trip) async throws -> [AIDetailResponse]
    func surpriseMe(request: SurpriseMeRequest) async throws -> SurpriseMeResponse
}
