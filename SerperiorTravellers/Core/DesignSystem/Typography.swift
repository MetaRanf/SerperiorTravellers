import SwiftUI

// MARK: - AppFont Helper
/// Centralizes creation of rounded system fonts (Airbnb uses rounded, friendly feel)
enum AppFont {
    /// Rounded system font with specified size and weight
    static func rounded(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// Cereal-inspired / rounded bold display
    static func display(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    // Predefined weight shortcuts
    static func thin(_ size: CGFloat) -> Font { rounded(size: size, weight: .thin) }
    static func light(_ size: CGFloat) -> Font { rounded(size: size, weight: .light) }
    static func regular(_ size: CGFloat) -> Font { rounded(size: size, weight: .regular) }
    static func medium(_ size: CGFloat) -> Font { rounded(size: size, weight: .medium) }
    static func semibold(_ size: CGFloat) -> Font { rounded(size: size, weight: .semibold) }
    static func bold(_ size: CGFloat) -> Font { rounded(size: size, weight: .bold) }
    static func heavy(_ size: CGFloat) -> Font { rounded(size: size, weight: .heavy) }
    static func black(_ size: CGFloat) -> Font { rounded(size: size, weight: .black) }
}

// MARK: - AppTypography
/// Airbnb-inspired typographic scale
/// All fonts use SF Rounded for warm, approachable feel
struct AppTypography {

    // MARK: Display / Large Titles - used for hero sections
    static let largeTitle = AppFont.bold(34)           // Airbnb search title
    static let largeTitleRegular = AppFont.regular(34)

    // MARK: Titles - section headers, detail titles
    static let title1 = AppFont.bold(28)
    static let title1Semibold = AppFont.semibold(28)
    static let title2 = AppFont.bold(22)
    static let title2Semibold = AppFont.semibold(22)
    static let title3 = AppFont.semibold(20)
    static let title3Bold = AppFont.bold(20)

    // MARK: Headline - card titles, list headings
    static let headline = AppFont.semibold(17)
    static let headlineBold = AppFont.bold(17)
    static let headlineSmall = AppFont.semibold(15)

    // MARK: Body - main readable text
    static let body = AppFont.regular(17)
    static let bodyMedium = AppFont.medium(17)
    static let bodySemibold = AppFont.semibold(17)
    static let bodyBold = AppFont.bold(17)

    static let bodyLarge = AppFont.regular(18)
    static let bodyLargeSemibold = AppFont.semibold(18)

    // MARK: Callout & Subheadline - secondary content
    static let callout = AppFont.regular(16)
    static let calloutMedium = AppFont.medium(16)
    static let calloutSemibold = AppFont.semibold(16)

    static let subheadline = AppFont.regular(15)
    static let subheadlineMedium = AppFont.medium(15)
    static let subheadlineSemibold = AppFont.semibold(15)

    // MARK: Footnote & Caption - metadata, labels
    static let footnote = AppFont.regular(13)
    static let footnoteMedium = AppFont.medium(13)
    static let footnoteSemibold = AppFont.semibold(13)

    static let caption1 = AppFont.regular(12)
    static let caption1Medium = AppFont.medium(12)
    static let caption1Semibold = AppFont.semibold(12)
    static let caption1Bold = AppFont.bold(12)

    static let caption2 = AppFont.regular(11)
    static let caption2Medium = AppFont.medium(11)
    static let caption2Semibold = AppFont.semibold(11)
    static let caption2Bold = AppFont.bold(11)

    static let caption = AppFont.regular(12) // alias for caption1

    // MARK: Button Labels
    static let buttonLarge = AppFont.semibold(17)
    static let buttonMedium = AppFont.semibold(16)
    static let buttonSmall = AppFont.semibold(14)

    // MARK: Price / Numeric Emphasis (Airbnb price is bold)
    static let price = AppFont.semibold(16)
    static let priceLarge = AppFont.bold(18)
    static let priceSmall = AppFont.semibold(14)

    // MARK: Badge / Labels
    static let badge = AppFont.bold(11)
    static let badgeMedium = AppFont.semibold(11)
    static let overline = AppFont.bold(11) // Uppercase labels
}

// MARK: - View Modifier for tracking & line spacing Airbnb style
struct AppTextStyle: ViewModifier {
    let font: Font
    var color: Color = AppColors.textPrimary
    var lineSpacing: CGFloat = 0
    var kerning: CGFloat = 0
    var isUppercase: Bool = false

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
            .lineSpacing(lineSpacing)
            .tracking(kerning)
    }
}

extension Text {
    func appFont(_ font: Font, color: Color = AppColors.textPrimary) -> some View {
        self.font(font).foregroundStyle(color)
    }
}

extension View {
    /// Apply AppTypography style quickly
    func typography(_ font: Font, color: Color = AppColors.textPrimary) -> some View {
        modifier(AppTextStyle(font: font, color: color))
    }

    func overlineStyle() -> some View {
        self.font(AppTypography.overline)
            .tracking(0.6)
            .textCase(.uppercase)
    }
}

// MARK: - Line Height Helpers (Airbnb uses generous line heights)
enum AppLineHeight {
    static let tight: CGFloat = 1.1
    static let normal: CGFloat = 1.3
    static let relaxed: CGFloat = 1.5
    static let loose: CGFloat = 1.7
}
