import Foundation

public struct UserPreferences: Codable, Equatable, Sendable, Hashable {
    public var currency: Currency
    public var temperatureUnit: TemperatureUnit
    public var language: AppLanguage
    public var isNotificationEnabled: Bool
    public var favoriteTypes: Set<FavoriteType>
    public var priceAlertsEnabled: Bool
    public var distanceUnit: DistanceUnit

    public init(
        currency: Currency = .usd,
        temperatureUnit: TemperatureUnit = .celsius,
        language: AppLanguage = .english,
        isNotificationEnabled: Bool = true,
        favoriteTypes: Set<FavoriteType> = [],
        priceAlertsEnabled: Bool = true,
        distanceUnit: DistanceUnit = .kilometers
    ) {
        self.currency = currency
        self.temperatureUnit = temperatureUnit
        self.language = language
        self.isNotificationEnabled = isNotificationEnabled
        self.favoriteTypes = favoriteTypes
        self.priceAlertsEnabled = priceAlertsEnabled
        self.distanceUnit = distanceUnit
    }

    public static var `default`: UserPreferences { UserPreferences() }
}

public enum TemperatureUnit: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
    public var id: String { rawValue }
    public var symbol: String { self == .celsius ? "°C" : "°F" }
    public var displayName: String { self == .celsius ? "Celsius" : "Fahrenheit" }
}

public enum DistanceUnit: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case kilometers = "km"
    case miles = "mi"
    public var id: String { rawValue }
    public var displayName: String { self == .kilometers ? "Kilometers" : "Miles" }
}

public enum AppLanguage: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case english = "en", spanish = "es", french = "fr", german = "de", japanese = "ja", chinese = "zh", arabic = "ar"
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .japanese: return "日本語"
        case .chinese: return "中文"
        case .arabic: return "العربية"
        }
    }
    public var locale: Locale { Locale(identifier: rawValue) }
}

public enum FavoriteType: String, Codable, CaseIterable, Equatable, Sendable, Hashable, Identifiable {
    case beach = "beach", mountain = "mountain", city = "city", adventure = "adventure",
         cultural = "cultural", tropical = "tropical", winter = "winter", luxury = "luxury",
         budget = "budget", family = "family", petFriendly = "pet_friendly"

    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .beach: return "Beach"
        case .mountain: return "Mountain"
        case .city: return "City Break"
        case .adventure: return "Adventure"
        case .cultural: return "Cultural"
        case .tropical: return "Tropical"
        case .winter: return "Winter"
        case .luxury: return "Luxury"
        case .budget: return "Budget"
        case .family: return "Family"
        case .petFriendly: return "Pet Friendly"
        }
    }
    public var systemIcon: String {
        switch self {
        case .beach: return "beach.umbrella"
        case .mountain: return "mountain.2"
        case .city: return "building.2"
        case .adventure: return "figure.hiking"
        case .cultural: return "building.columns"
        case .tropical: return "leaf"
        case .winter: return "snowflake"
        case .luxury: return "star"
        case .budget: return "dollarsign.circle"
        case .family: return "person.2"
        case .petFriendly: return "pawprint.fill"
        }
    }
}
