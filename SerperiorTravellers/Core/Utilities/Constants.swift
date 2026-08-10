import Foundation

public enum AppConstants {
    public static let appName = "Serperior Travellers"
    public static let bundleId = "com.serperiortravellers.app"
    public static let appVersion = "1.0.0"
    public static let supportEmail = "support@serperior.app"

    public struct FeatureFlags {
        public static let enableAIAssistant = true
        public static let enablePriceTracker = true
        public static let enableCollaboration = true
        public static let enableWeatherAlerts = true
        public static let useMockServices = true
    }

    public struct APIKeys {
        public static let amadeus = ""
        public static let bookingCom = ""
        public static let openWeather = ""
        public static let mapBox = ""
    }

    public struct UI {
        public static let cornerRadius: Double = 16
        public static let cardCornerRadius: Double = 20
        public static let searchBarHeight: Double = 56
        public static let tabBarHeight: Double = 49
        public static let maxContentWidth: Double = 600
    }

    public struct Pagination {
        public static let pageSize = 20
        public static let prefetchThreshold = 5
    }

    public struct Defaults {
        public static let defaultCurrency: Currency = .usd
        public static let cacheExpiration: TimeInterval = 3600
    }
}
