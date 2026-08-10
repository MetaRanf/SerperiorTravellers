import SwiftUI

// MARK: - Color Hex Initializer
extension Color {
    /// Initialize Color from hex string like "#FF385C" or "FF385C"
    init(hex: String, opacity: Double = 1.0) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let r, g, b: Double
        if sanitized.count == 6 {
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
        } else {
            r = 1; g = 1; b = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    /// Adaptive color that switches between light and dark variants
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - AppColors
/// Airbnb-inspired semantic color system
/// Supports light / dark appearance via adaptive colors
struct AppColors {

    // MARK: Brand
    static let primary = Color(hex: "#FF385C")
    static let primaryLight = Color(hex: "#FF6B8A")
    static let primaryDark = Color(hex: "#D9324E")
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#FF385C"), Color(hex: "#E31C5F")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let secondary = Color(hex: "#222222")
    static let secondaryLight = Color(hex: "#484848")

    static let accent = Color(hex: "#00A699")          // Airbnb teal
    static let accentLight = Color(hex: "#33B8AC")

    // MARK: Semantic Backgrounds
    static let background = Color.adaptive(
        light: Color(hex: "#FFFFFF"),
        dark: Color(hex: "#000000")
    )
    static let backgroundSecondary = Color.adaptive(
        light: Color(hex: "#F7F7F7"),
        dark: Color(hex: "#121212")
    )
    static let cardBackground = Color.adaptive(
        light: Color(hex: "#FFFFFF"),
        dark: Color(hex: "#1C1C1E")
    )
    static let groupedBackground = Color.adaptive(
        light: Color(hex: "#F7F7F7"),
        dark: Color(hex: "#000000")
    )

    // MARK: Text
    static let textPrimary = Color.adaptive(
        light: Color(hex: "#222222"),
        dark: Color(hex: "#F5F5F5")
    )
    static let textSecondary = Color.adaptive(
        light: Color(hex: "#717171"),
        dark: Color(hex: "#A0A0A0")
    )
    static let textTertiary = Color.adaptive(
        light: Color(hex: "#B0B0B0"),
        dark: Color(hex: "#6E6E6E")
    )
    static let textInverse = Color.adaptive(
        light: Color.white,
        dark: Color(hex: "#222222")
    )
    static let textOnPrimary = Color.white

    // MARK: Border & Separator
    static let border = Color.adaptive(
        light: Color(hex: "#DDDDDD"),
        dark: Color(hex: "#383838")
    )
    static let borderLight = Color.adaptive(
        light: Color(hex: "#EBEBEB"),
        dark: Color(hex: "#2C2C2E")
    )
    static let separator = Color.adaptive(
        light: Color(hex: "#EBEBEB"),
        dark: Color(hex: "#38383A")
    )

    // MARK: Status
    static let success = Color(hex: "#00A699")
    static let successLight = Color(hex: "#E6F7F5")
    static let successDark = Color(hex: "#008489")

    static let warning = Color(hex: "#FFB400")
    static let warningLight = Color(hex: "#FFF8E6")
    static let warningDark = Color(hex: "#CC9000")

    static let error = Color(hex: "#C13515")
    static let errorLight = Color(hex: "#FCE8E3")
    static let errorDark = Color(hex: "#A12C11")

    static let info = Color(hex: "#007A87")
    static let infoLight = Color(hex: "#E0F2F3")

    // MARK: Shadow & Overlay
    static let shadow = Color.black.opacity(0.10)
    static let shadowMedium = Color.black.opacity(0.16)
    static let shadowStrong = Color.black.opacity(0.24)
    static let shadowColor = Color.adaptive(
        light: Color.black.opacity(0.10),
        dark: Color.black.opacity(0.40)
    )
    static let overlay = Color.black.opacity(0.4)
    static let overlayLight = Color.black.opacity(0.24)
    static let scrim = Color.black.opacity(0.6)

    // MARK: Badges
    static let hotBadgeBackground = Color(hex: "#FF385C")
    static let hotBadgeText = Color.white

    static let trendingBadgeBackground = Color(hex: "#222222")
    static let trendingBadgeText = Color.white

    static let superhostBadgeBackground = Color.adaptive(
        light: Color.white,
        dark: Color(hex: "#2C2C2E")
    )
    static let superhostBadgeText = AppColors.textPrimary

    static let categoryBadgeBackground = Color.adaptive(
        light: Color(hex: "#F7F7F7"),
        dark: Color(hex: "#2C2C2E")
    )
    static let newBadgeBackground = Color(hex: "#00A699")

    // MARK: Interactive
    static let heartEmpty = Color.adaptive(
        light: Color.white.opacity(0.9),
        dark: Color.white.opacity(0.9)
    )
    static let heartFilled = Color(hex: "#FF385C")

    static let star = Color(hex: "#FFB400")

    static let shimmerBase = Color.adaptive(
        light: Color(hex: "#EBEBEB"),
        dark: Color(hex: "#2C2C2E")
    )
    static let shimmerHighlight = Color.adaptive(
        light: Color(hex: "#F7F7F7"),
        dark: Color(hex: "#3A3A3C")
    )

    // MARK: Map / Location
    static let mapPin = Color(hex: "#FF385C")
    static let locationAccent = Color(hex: "#007A87")
}

// MARK: - Color Palette Preview Helper
extension AppColors {
    static let allBrand: [Color] = [primary, secondary, accent]
    static let allSemantic: [(String, Color)] = [
        ("background", background),
        ("cardBackground", cardBackground),
        ("textPrimary", textPrimary),
        ("textSecondary", textSecondary),
        ("border", border),
        ("shadow", shadow)
    ]
}
